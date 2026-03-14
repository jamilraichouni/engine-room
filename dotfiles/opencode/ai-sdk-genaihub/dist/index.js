// src/genaihub-provider.ts
import {
  loadApiKey,
  withoutTrailingSlash
} from "@ai-sdk/provider-utils";

// src/genaihub-language-model.ts
import {
  extractResponseHeaders,
  generateId
} from "@ai-sdk/provider-utils";

// src/convert-to-bedrock.ts
import { convertUint8ArrayToBase64 } from "@ai-sdk/provider-utils";
function convertFilePart(part) {
  const mediaType = part.mediaType ?? "application/octet-stream";
  if (mediaType.startsWith("image/")) {
    let data;
    if (typeof part.data === "string") {
      data = part.data;
    } else if (part.data instanceof Uint8Array) {
      data = convertUint8ArrayToBase64(part.data);
    } else if (part.data instanceof URL) {
      return { type: "text", text: `[Image: ${part.data.toString()}]` };
    } else {
      return { type: "text", text: "[Unsupported file data]" };
    }
    return {
      type: "image",
      source: { type: "base64", media_type: mediaType, data }
    };
  }
  return { type: "text", text: "[Unsupported file type]" };
}
function convertUserContent(content) {
  const parts = [];
  for (const part of content) {
    if (part.type === "text") {
      parts.push({ type: "text", text: part.text });
    } else if (part.type === "file") {
      parts.push(convertFilePart(part));
    }
  }
  return parts;
}
function convertAssistantContent(content) {
  const parts = [];
  for (const part of content) {
    if (part.type === "text") {
      if (part.text.length > 0) {
        parts.push({ type: "text", text: part.text });
      }
    } else if (part.type === "tool-call") {
      parts.push({
        type: "tool_use",
        id: part.toolCallId,
        name: part.toolName,
        input: part.input
      });
    }
  }
  return parts;
}
function convertToolContent(content) {
  const parts = [];
  for (const part of content) {
    if (part.type === "tool-result") {
      let resultContent;
      const output = part.output;
      if (output.type === "text" || output.type === "error-text") {
        resultContent = output.value;
      } else if (output.type === "json" || output.type === "error-json") {
        resultContent = JSON.stringify(output.value);
      } else {
        resultContent = JSON.stringify(output.value);
      }
      parts.push({
        type: "tool_result",
        tool_use_id: part.toolCallId,
        content: resultContent
      });
    }
  }
  return parts;
}
function convertTools(tools) {
  if (!tools || tools.length === 0) return void 0;
  const result = [];
  for (const tool of tools) {
    if (tool.type === "function") {
      result.push({
        name: tool.name,
        description: tool.description,
        input_schema: tool.inputSchema
      });
    }
  }
  return result.length > 0 ? result : void 0;
}
function convertToolChoice(toolChoice) {
  if (!toolChoice) return void 0;
  switch (toolChoice.type) {
    case "auto":
      return { type: "auto" };
    case "none":
      return void 0;
    case "required":
      return { type: "any" };
    case "tool":
      return { type: "tool", name: toolChoice.toolName };
    default:
      return void 0;
  }
}
function convertToBedrock(prompt, options) {
  const warnings = [];
  const systemParts = [];
  const messages = [];
  for (const message of prompt) {
    switch (message.role) {
      case "system":
        systemParts.push(message.content);
        break;
      case "user":
        messages.push({
          role: "user",
          content: convertUserContent(message.content)
        });
        break;
      case "assistant":
        messages.push({
          role: "assistant",
          content: convertAssistantContent(message.content)
        });
        break;
      case "tool":
        messages.push({
          role: "user",
          content: convertToolContent(message.content)
        });
        break;
    }
  }
  if (messages.length > 0 && messages[messages.length - 1].role === "assistant") {
    messages.pop();
  }
  const body = {
    anthropic_version: "bedrock-2023-05-31",
    messages,
    max_tokens: options.maxOutputTokens ?? 4096
  };
  if (systemParts.length > 0) {
    body.system = systemParts.join("\n\n");
  }
  if (options.temperature !== void 0) {
    body.temperature = options.temperature;
  }
  if (options.topP !== void 0) {
    body.top_p = options.topP;
  }
  if (options.topK !== void 0) {
    body.top_k = options.topK;
  }
  if (options.stopSequences !== void 0 && options.stopSequences.length > 0) {
    body.stop_sequences = options.stopSequences;
  }
  const tools = convertTools(options.tools);
  if (tools) {
    body.tools = tools;
  }
  const toolChoice = convertToolChoice(options.toolChoice);
  if (toolChoice) {
    body.tool_choice = toolChoice;
  }
  if (options.frequencyPenalty !== void 0) {
    warnings.push({
      type: "unsupported-setting",
      setting: "frequencyPenalty"
    });
  }
  if (options.presencePenalty !== void 0) {
    warnings.push({
      type: "unsupported-setting",
      setting: "presencePenalty"
    });
  }
  if (options.seed !== void 0) {
    warnings.push({
      type: "unsupported-setting",
      setting: "seed"
    });
  }
  return { body, warnings };
}

// src/convert-from-bedrock.ts
function mapFinishReason(stopReason) {
  switch (stopReason) {
    case "end_turn":
      return "stop";
    case "stop_sequence":
      return "stop";
    case "tool_use":
      return "tool-calls";
    case "max_tokens":
      return "length";
    case "content_filtered":
      return "content-filter";
    default:
      return "other";
  }
}
function extractUsage(response) {
  const inputTokens = response.usage?.input_tokens ?? 0;
  const outputTokens = response.usage?.output_tokens ?? 0;
  return {
    inputTokens,
    outputTokens,
    totalTokens: inputTokens + outputTokens
  };
}
function convertContent(response) {
  const result = [];
  for (const block of response.content ?? []) {
    if (block.type === "text" && block.text !== void 0) {
      result.push({ type: "text", text: block.text });
    } else if (block.type === "tool_use") {
      result.push({
        type: "tool-call",
        toolCallId: block.id ?? "",
        toolName: block.name ?? "",
        input: typeof block.input === "string" ? block.input : JSON.stringify(block.input ?? {})
      });
    }
  }
  return result;
}

// src/genaihub-language-model.ts
var GenaihubLanguageModel = class {
  specificationVersion = "v2";
  provider;
  modelId;
  defaultObjectGenerationMode = "tool";
  supportedUrls = {};
  config;
  constructor(modelId, config) {
    this.provider = config.provider;
    this.modelId = modelId;
    this.config = config;
  }
  buildUrl() {
    const encoded = encodeURIComponent(this.modelId);
    return `${this.config.baseURL}/model/${encoded}/invoke`;
  }
  buildHeaders() {
    return {
      ...this.config.headers(),
      "Content-Type": "application/json",
      "Ocp-Apim-Subscription-Key": this.config.apiKey()
    };
  }
  async invoke(options) {
    const { body, warnings } = convertToBedrock(
      options.prompt,
      options
    );
    const fetchFn = this.config.fetch ?? globalThis.fetch;
    const url = this.buildUrl();
    const response = await fetchFn(url, {
      method: "POST",
      headers: this.buildHeaders(),
      body: JSON.stringify(body),
      signal: options.abortSignal
    });
    const responseHeaders = extractResponseHeaders(response);
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `GenAI Hub API error ${response.status}: ${errorText}`
      );
    }
    const raw = await response.json();
    const content = convertContent(raw);
    const usage = extractUsage(raw);
    const finishReason = mapFinishReason(raw.stop_reason);
    return {
      body,
      raw,
      content,
      usage,
      finishReason,
      responseHeaders,
      warnings
    };
  }
  async doGenerate(options) {
    const result = await this.invoke(options);
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
        body: result.raw
      }
    };
  }
  async doStream(options) {
    const result = await this.invoke(options);
    const modelId = result.raw.model ?? this.modelId;
    const rawId = result.raw.id;
    const stream = new ReadableStream({
      start(controller) {
        controller.enqueue({
          type: "response-metadata",
          id: rawId,
          modelId
        });
        for (const part of result.content) {
          if (part.type === "text") {
            const blockId = generateId();
            controller.enqueue({
              type: "text-start",
              id: blockId
            });
            controller.enqueue({
              type: "text-delta",
              id: blockId,
              delta: part.text
            });
            controller.enqueue({
              type: "text-end",
              id: blockId
            });
          } else if (part.type === "tool-call") {
            controller.enqueue({
              type: "tool-input-start",
              id: part.toolCallId,
              toolName: part.toolName
            });
            controller.enqueue({
              type: "tool-input-delta",
              id: part.toolCallId,
              delta: part.input
            });
            controller.enqueue({
              type: "tool-input-end",
              id: part.toolCallId
            });
            controller.enqueue({
              type: "tool-call",
              toolCallId: part.toolCallId,
              toolName: part.toolName,
              input: part.input
            });
          }
        }
        controller.enqueue({
          type: "finish",
          finishReason: result.finishReason,
          usage: result.usage
        });
        controller.close();
      }
    });
    return {
      stream,
      request: { body: result.body },
      response: {
        headers: result.responseHeaders
      }
    };
  }
};

// src/genaihub-provider.ts
function createGenaihub(options = {}) {
  const providerName = options.name ?? "genaihub";
  const getBaseURL = () => withoutTrailingSlash(options.baseURL) ?? "https://genaihub-gateway.genai-prod.comp.db.de/claude";
  const getApiKey = () => loadApiKey({
    apiKey: options.apiKey,
    environmentVariableName: "AWS_BEARER_TOKEN_BEDROCK",
    description: "GenAI Hub APIM subscription key"
  });
  const getHeaders = () => options.headers ?? {};
  const createLanguageModel = (modelId) => new GenaihubLanguageModel(modelId, {
    provider: providerName,
    baseURL: getBaseURL(),
    apiKey: getApiKey,
    headers: getHeaders,
    fetch: options.fetch
  });
  const provider = (modelId) => createLanguageModel(modelId);
  provider.languageModel = createLanguageModel;
  provider.textEmbeddingModel = (_modelId) => {
    throw new Error("GenAI Hub does not support embedding models");
  };
  return provider;
}
export {
  createGenaihub
};
