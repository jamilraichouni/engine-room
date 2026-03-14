import type {
  LanguageModelV2,
  LanguageModelV2CallOptions,
  LanguageModelV2StreamPart,
} from "@ai-sdk/provider"
import {
  extractResponseHeaders,
  generateId,
} from "@ai-sdk/provider-utils"
import { convertToBedrock } from "./convert-to-bedrock.js"
import {
  type BedrockResponse,
  convertContent,
  extractUsage,
  mapFinishReason,
} from "./convert-from-bedrock.js"

export interface GenaihubModelConfig {
  provider: string
  baseURL: string
  apiKey: () => string
  headers: () => Record<string, string>
  fetch?: typeof globalThis.fetch
}

export class GenaihubLanguageModel implements LanguageModelV2 {
  readonly specificationVersion = "v2" as const
  readonly provider: string
  readonly modelId: string
  readonly defaultObjectGenerationMode = "tool" as const
  readonly supportedUrls = {}

  private readonly config: GenaihubModelConfig

  constructor(modelId: string, config: GenaihubModelConfig) {
    this.provider = config.provider
    this.modelId = modelId
    this.config = config
  }

  private buildUrl(): string {
    const encoded = encodeURIComponent(this.modelId)
    return `${this.config.baseURL}/model/${encoded}/invoke`
  }

  private buildHeaders(): Record<string, string> {
    return {
      ...this.config.headers(),
      "Content-Type": "application/json",
      "Ocp-Apim-Subscription-Key": this.config.apiKey(),
    }
  }

  private async invoke(options: LanguageModelV2CallOptions) {
    const { body, warnings } = convertToBedrock(
      options.prompt,
      options,
    )

    const fetchFn = this.config.fetch ?? globalThis.fetch
    const url = this.buildUrl()

    const response = await fetchFn(url, {
      method: "POST",
      headers: this.buildHeaders(),
      body: JSON.stringify(body),
      signal: options.abortSignal,
    })

    const responseHeaders = extractResponseHeaders(response)

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(
        `GenAI Hub API error ${response.status}: ${errorText}`,
      )
    }

    const raw = await response.json() as BedrockResponse
    const content = convertContent(raw)
    const usage = extractUsage(raw)
    const finishReason = mapFinishReason(raw.stop_reason)

    return {
      body,
      raw,
      content,
      usage,
      finishReason,
      responseHeaders,
      warnings,
    }
  }

  async doGenerate(options: LanguageModelV2CallOptions) {
    const result = await this.invoke(options)

    return {
      content: result.content,
      finishReason: result.finishReason,
      usage: result.usage,
      warnings: result.warnings,
      request: { body: result.body },
      response: {
        id: result.raw.id,
        modelId: result.raw.model ?? this.modelId,
        headers: result.responseHeaders,
        body: result.raw,
      },
    }
  }

  async doStream(options: LanguageModelV2CallOptions) {
    const result = await this.invoke(options)

    const modelId = result.raw.model ?? this.modelId
    const rawId = result.raw.id

    const stream = new ReadableStream<LanguageModelV2StreamPart>({
      start(controller) {
        controller.enqueue({
          type: "response-metadata",
          id: rawId,
          modelId,
        })

        for (const part of result.content) {
          if (part.type === "text") {
            const blockId = generateId()
            controller.enqueue({
              type: "text-start",
              id: blockId,
            })
            controller.enqueue({
              type: "text-delta",
              id: blockId,
              delta: part.text,
            })
            controller.enqueue({
              type: "text-end",
              id: blockId,
            })
          } else if (part.type === "tool-call") {
            controller.enqueue({
              type: "tool-input-start",
              id: part.toolCallId,
              toolName: part.toolName,
            })
            controller.enqueue({
              type: "tool-input-delta",
              id: part.toolCallId,
              delta: part.input,
            })
            controller.enqueue({
              type: "tool-input-end",
              id: part.toolCallId,
            })
            controller.enqueue({
              type: "tool-call",
              toolCallId: part.toolCallId,
              toolName: part.toolName,
              input: part.input,
            })
          }
        }

        controller.enqueue({
          type: "finish",
          finishReason: result.finishReason,
          usage: result.usage,
        })

        controller.close()
      },
    })

    return {
      stream,
      request: { body: result.body },
      response: {
        headers: result.responseHeaders,
      },
    }
  }
}
