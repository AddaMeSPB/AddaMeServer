//
//  AppConfig.swift
//  
//
//  Created by Saroar Khandoker on 20.01.2022.
//

import Vapor

struct AppConfig {
	let frontendURL: String
	let apiURL: String
	let noReplyEmail: String
    static var env: Environment = .development

	static var environment: AppConfig {
        let environmentNameUppercased = env.name.uppercased()
		guard
			let frontendURL = Environment.get("SITE_FRONTEND_URL_\(environmentNameUppercased)"),
			let apiURL = Environment.get("SITE_API_URL_\(environmentNameUppercased)"),
			let noReplyEmail = Environment.get("NO_REPLY_EMAIL_\(environmentNameUppercased)")
		else {
			fatalError("Please add app configuration to environment variables")
		}

		return .init(frontendURL: frontendURL, apiURL: apiURL, noReplyEmail: noReplyEmail)
	}
}

extension Application {
	struct AppConfigKey: StorageKey {
		typealias Value = AppConfig
	}

	var config: AppConfig {
		get {
			storage[AppConfigKey.self] ?? .environment
		}
		set {
			storage[AppConfigKey.self] = newValue
		}
	}
}
