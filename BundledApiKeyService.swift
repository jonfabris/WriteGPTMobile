//
//  VendorProvider.swift
//  WriteGPT
//
//  Created by Jon Fabris on 8/13/24.
//

import Foundation

struct BundledApiKeyService {
    static let fileName = "APIKeysSecret"

    struct ApiKeys: Codable {
        let ChatGptApiKey: String
        let ChatGptOrganization: String
    }

    var apiKeys: ApiKeys?

    init() {
        let infoPlistPath = Bundle.main.url(
            forResource: Self.fileName,
            withExtension: "plist"
        )!

        do {
            let infoPlistData = try Data(contentsOf: infoPlistPath)
            apiKeys = try PropertyListDecoder().decode(
                ApiKeys.self,
                from: infoPlistData
            )
        } catch {
            print(error)
        }
    }
}
