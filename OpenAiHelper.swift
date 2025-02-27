//
//  OpenAiHelper.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/13/24.
//

import Foundation
import OpenAIKit

// https://mrprogrammer.medium.com/integrating-openai-api-into-ios-application-using-swift-42b96614458b


struct OpenAIError: Error {
    let message: String
}

class OpenAiHelper {
    private var openAI: OpenAI?
    
    init() {
        let apiKeyService = BundledApiKeyService()
        let apiKey = apiKeyService.apiKeys!.ChatGptApiKey
        let organization = apiKeyService.apiKeys!.ChatGptOrganization
        openAI = OpenAI(Configuration(organizationId: organization, apiKey: apiKey))
    }
    
    func sendChatPrompt(_ prompt: String) async throws -> String {
        guard let openAI = openAI else {
            throw OpenAIError(message: "openAI not initialized")
        }
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OpenAIError(message: "Empty prompt")
        }
        
        do {
            let params = ChatParameters(
                model: .gpt4,
                messages: [ChatMessage(role: .user, content: prompt)]
            )
            
            let result = try await openAI.generateChatCompletion(parameters: params)
            if let content = result.choices.first?.message?.content {
                return content
            } else {
                throw OpenAIError(message: "No response received")
            }
        } catch {
            throw OpenAIError(message: error.localizedDescription)
        }
    }
    
    func sendImagePrompt(prompt: String) async throws -> String {
        guard let openAI = openAI else {
            throw OpenAIError(message: "openAI not initialized")
        }
        do {
            let params = ImageParameters(
                prompt: prompt, model: .dalle2
            )
            
            let result = try await openAI.createImage(parameters: params)
            if let imageData = result.data.first {
                switch imageData {
                case .url(let filename):
                    return filename
                case .b64Json(_):
                    return "json format"
                }
            }
            throw OpenAIError(message: "No response received")
        } catch {
            throw OpenAIError(message: error.localizedDescription)
        }
    }
}

// [1]    (null)    "message" : "You exceeded your current quota, please check your plan and billing details. For more information on this error, read the docs: https://platform.openai.com/docs/guides/error-codes/api-errors."

