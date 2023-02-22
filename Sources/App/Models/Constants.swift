//
//  Constants.swift
//  
//
//  Created by Saroar Khandoker on 20.01.2022.
//

public struct Constants {
	/// How long should access tokens live for. Default: 1 year (in seconds)
    public static let ACCESS_TOKEN_LIFETIME: Double = 60 * 60 * 24 * 365
	/// How long should refresh tokens live for: Default: 7 days (in seconds)
    public static let REFRESH_TOKEN_LIFETIME: Double = 60 * 60 * 24 * 7
	/// How long should the email tokens live for: Default 24 hours (in seconds)
    public static let EMAIL_TOKEN_LIFETIME: Double = 60 * 60 * 24
	/// Lifetime of reset password tokens: Default 1 hour (seconds)
    public static let RESET_PASSWORD_TOKEN_LIFETIME: Double = 60 * 60
}
