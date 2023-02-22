//
//  RefreshToken.swift
//  
//
//  Created by Saroar Khandoker on 20.01.2022.
//

import Vapor
import Fluent
import BSON
import JWT
import AddaSharedModels

public final class RefreshTokenModel: Model {
    public static let schema = "user_refresh_tokens"

	@ID(custom: "id") public var id: ObjectId?
	@Field(key: "token") public var token: String
	@Parent(key: "userId") public var user: UserModel

	@Field(key: "expiresAt") public var expiresAt: Date
	@Field(key: "issuedAt") public var issuedAt: Date

    public init() {}

    public init(
        id: ObjectId? = nil,
        token: String,
        userID: ObjectId,
        expiresAt: Date = Date().addingTimeInterval(Constants.REFRESH_TOKEN_LIFETIME),
        issuedAt: Date = Date()
    ) {
		self.id = id
		self.token = token
		self.$user.id = userID
		self.expiresAt = expiresAt
		self.issuedAt = issuedAt
	}
}

public struct JWTRefreshToken: JWTPayload {
    public var id: ObjectId?
    public var iat: Int
    public var exp: Int

  public init(user: UserModel, expiration: Int = 31536000) { // Expiration 1 year
        let now = Date().timeIntervalSince1970
        self.id = user.id
        self.iat = Int(now)
        self.exp = Int(now) + expiration
    }

   public func verify(using signer: JWTSigner) throws {
        let expiration = Date(timeIntervalSince1970: TimeInterval(self.exp))
        try ExpirationClaim(value: expiration).verifyNotExpired()
    }
}
