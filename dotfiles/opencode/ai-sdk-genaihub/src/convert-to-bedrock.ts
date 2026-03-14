import type {
  LanguageModelV2Prompt,
  LanguageModelV2CallOptions,
  LanguageModelV2CallWarning,
} from "@ai-sdk/provider"
import { convertUint8ArrayToBase64 } from "@ai-sdk/provider-utils"

interface BedrockContent {
  type: string
  text?: string
  id?: string
  name?: string
  input?: unknown
  tool_use_id?: string
  content?: unknown
  source?: { type: string; media_type: string; data: string }
}

interface BedrockMessage {
  role: string
  content: string | BedrockContent[]
}

interface BedrockTool {
  name: string
  description?: string
  input_schema: unknown
}

export interface BedrockRequest {
  anthropic_version: string
  system?: string | Array<{ type: string; text: string }>
  messages: BedrockMessage[]
  max_tokens: number
  temperature?: number
  top_p?: number
  top_k?: number
  stop_sequences?: string[]
  tools?: BedrockTool[]
  tool_choice?: unknown
}

function convertFilePart(
  part: Extract<
    LanguageModelV2Prompt[number]["content"][number],
    { type: "file" }
  >,
): BedrockContent {
  const mediaType = part.mediaType ?? "application/octet-stream"
  if (mediaType.startsWith("image/")) {
    let data: string
    if (typeof part.data === "string") {
      data = part.data
    } else if (part.data instanceof Uint8Array) {
      data = convertUint8ArrayToBase64(part.data)
    } else if (part.data instanceof URL) {
      return { type: "text", text: `[Image: ${part.data.toString()}]` }
    } else {
      return { type: "text", text: "[Unsupported file data]" }
    }
    return {
      type: "image",
      source: { type: "base64", media_type: mediaType, data },
    }
  }
  return { type: "text", text: "[Unsupported file type]" }
}

function convertUserContent(
  content: Extract<
    LanguageModelV2Prompt[number],
    { role: "user" }
  >["content"],
): BedrockContent[] {
  const parts: BedrockContent[] = []
  for (const part of content) {
    if (part.type === "text") {
      parts.push({ type: "text", text: part.text })
    } else if (part.type === "file") {
      parts.push(convertFilePart(part))
    }
  }
  return parts
}

function convertAssistantContent(
  content: Extract<
    LanguageModelV2Prompt[number],
    { role: "assistant" }
  >["content"],
): BedrockContent[] {
  const parts: BedrockContent[] = []
  for (const part of content) {
    if (part.type === "text") {
      if (part.text.length > 0) {
        parts.push({ type: "text", text: part.text })
      }
    } else if (part.type === "tool-call") {
      parts.push({
        type: "tool_use",
        id: part.toolCallId,
        name: part.toolName,
        input: part.input,
      })
    }
  }
  return parts
}

function convertToolContent(
  content: Extract<
    LanguageModelV2Prompt[number],
    { role: "tool" }
  >["content"],
): BedrockContent[] {
  const parts: BedrockContent[] = []
  for (const part of content) {
    if (part.type === "tool-result") {
      let resultContent: unknown
      const output = part.output
      if (output.type === "text" || output.type === "error-text") {
        resultContent = output.value
      } else if (output.type === "json" || output.type === "error-json") {
        resultContent = JSON.stringify(output.value)
      } else {
        resultContent = JSON.stringify(output.value)
      }
      parts.push({
        type: "tool_result",
        tool_use_id: part.toolCallId,
        content: resultContent,
      })
    }
  }
  return parts
}

function convertTools(
  tools: LanguageModelV2CallOptions["tools"],
): BedrockTool[] | undefined {
  if (!tools || tools.length === 0) return undefined
  const result: BedrockTool[] = []
  for (const tool of tools) {
    if (tool.type === "function") {
      result.push({
        name: tool.name,
        description: tool.description,
        input_schema: tool.inputSchema,
      })
    }
  }
  return result.length > 0 ? result : undefined
}

function convertToolChoice(
  toolChoice: LanguageModelV2CallOptions["toolChoice"],
): unknown | undefined {
  if (!toolChoice) return undefined
  switch (toolChoice.type) {
    case "auto":
      return { type: "auto" }
    case "none":
      return undefined
    case "required":
      return { type: "any" }
    case "tool":
      return { type: "tool", name: toolChoice.toolName }
    default:
      return undefined
  }
}

export function convertToBedrock(
  prompt: LanguageModelV2Prompt,
  options: LanguageModelV2CallOptions,
): { body: BedrockRequest; warnings: LanguageModelV2CallWarning[] } {
  const warnings: LanguageModelV2CallWarning[] = []
  const systemParts: string[] = []
  const messages: BedrockMessage[] = []

  for (const message of prompt) {
    switch (message.role) {
      case "system":
        systemParts.push(message.content)
        break
      case "user":
        messages.push({
          role: "user",
          content: convertUserContent(message.content),
        })
        break
      case "assistant":
        messages.push({
          role: "assistant",
          content: convertAssistantContent(message.content),
        })
        break
      case "tool":
        messages.push({
          role: "user",
          content: convertToolContent(message.content),
        })
        break
    }
  }

  if (
    messages.length > 0 &&
    messages[messages.length - 1].role === "assistant"
  ) {
    messages.pop()
  }

  const body: BedrockRequest = {
    anthropic_version: "bedrock-2023-05-31",
    messages,
    max_tokens: options.maxOutputTokens ?? 4096,
  }

  if (systemParts.length > 0) {
    body.system = systemParts.join("\n\n")
  }

  if (options.temperature !== undefined) {
    body.temperature = options.temperature
  }
  if (options.topP !== undefined) {
    body.top_p = options.topP
  }
  if (options.topK !== undefined) {
    body.top_k = options.topK
  }
  if (options.stopSequences !== undefined && options.stopSequences.length > 0) {
    body.stop_sequences = options.stopSequences
  }

  const tools = convertTools(options.tools)
  if (tools) {
    body.tools = tools
  }

  const toolChoice = convertToolChoice(options.toolChoice)
  if (toolChoice) {
    body.tool_choice = toolChoice
  }

  if (options.frequencyPenalty !== undefined) {
    warnings.push({
      type: "unsupported-setting",
      setting: "frequencyPenalty",
    })
  }
  if (options.presencePenalty !== undefined) {
    warnings.push({
      type: "unsupported-setting",
      setting: "presencePenalty",
    })
  }
  if (options.seed !== undefined) {
    warnings.push({
      type: "unsupported-setting",
      setting: "seed",
    })
  }

  return { body, warnings }
}
