import type {
  LanguageModelV2Content,
  LanguageModelV2FinishReason,
  LanguageModelV2Usage,
} from "@ai-sdk/provider"

export interface BedrockResponse {
  id?: string
  model?: string
  type?: string
  role?: string
  content?: BedrockResponseContent[]
  stop_reason?: string
  stop_sequence?: string | null
  usage?: {
    input_tokens?: number
    output_tokens?: number
  }
}

interface BedrockResponseContent {
  type: string
  text?: string
  id?: string
  name?: string
  input?: unknown
}

export function mapFinishReason(
  stopReason: string | undefined,
): LanguageModelV2FinishReason {
  switch (stopReason) {
    case "end_turn":
      return "stop"
    case "stop_sequence":
      return "stop"
    case "tool_use":
      return "tool-calls"
    case "max_tokens":
      return "length"
    case "content_filtered":
      return "content-filter"
    default:
      return "other"
  }
}

export function extractUsage(
  response: BedrockResponse,
): LanguageModelV2Usage {
  const inputTokens = response.usage?.input_tokens ?? 0
  const outputTokens = response.usage?.output_tokens ?? 0
  return {
    inputTokens,
    outputTokens,
    totalTokens: inputTokens + outputTokens,
  }
}

export function convertContent(
  response: BedrockResponse,
): LanguageModelV2Content[] {
  const result: LanguageModelV2Content[] = []
  for (const block of response.content ?? []) {
    if (block.type === "text" && block.text !== undefined) {
      result.push({ type: "text", text: block.text })
    } else if (block.type === "tool_use") {
      result.push({
        type: "tool-call",
        toolCallId: block.id ?? "",
        toolName: block.name ?? "",
        input: typeof block.input === "string"
          ? block.input
          : JSON.stringify(block.input ?? {}),
      })
    }
  }
  return result
}
