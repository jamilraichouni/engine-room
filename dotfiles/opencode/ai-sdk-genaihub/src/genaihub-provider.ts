import type { LanguageModelV2, EmbeddingModelV2 } from "@ai-sdk/provider"
import {
  loadApiKey,
  withoutTrailingSlash,
} from "@ai-sdk/provider-utils"
import { GenaihubLanguageModel } from "./genaihub-language-model.js"

export interface GenaihubProviderSettings {
  name?: string
  baseURL?: string
  apiKey?: string
  headers?: Record<string, string>
  fetch?: typeof globalThis.fetch
}

export interface GenaihubProvider {
  (modelId: string): LanguageModelV2
  languageModel(modelId: string): LanguageModelV2
  textEmbeddingModel(modelId: string): EmbeddingModelV2<string>
}

export function createGenaihub(
  options: GenaihubProviderSettings = {},
): GenaihubProvider {
  const providerName = options.name ?? "genaihub"

  const getBaseURL = () =>
    withoutTrailingSlash(options.baseURL) ??
    "https://genaihub-gateway.genai-prod.comp.db.de/claude"

  const getApiKey = () =>
    loadApiKey({
      apiKey: options.apiKey,
      environmentVariableName: "AWS_BEARER_TOKEN_BEDROCK",
      description: "GenAI Hub APIM subscription key",
    })

  const getHeaders = () => options.headers ?? {}

  const createLanguageModel = (modelId: string): LanguageModelV2 =>
    new GenaihubLanguageModel(modelId, {
      provider: providerName,
      baseURL: getBaseURL(),
      apiKey: getApiKey,
      headers: getHeaders,
      fetch: options.fetch,
    })

  const provider = (modelId: string) => createLanguageModel(modelId)

  provider.languageModel = createLanguageModel

  provider.textEmbeddingModel = (_modelId: string) => {
    throw new Error("GenAI Hub does not support embedding models")
  }

  return provider as GenaihubProvider
}
