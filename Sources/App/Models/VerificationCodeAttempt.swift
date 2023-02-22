import Vapor
import Fluent
import BSON

public final class VerificationCodeAttempt: Model, Content {
    static public let schema = "verification_code_attempts"

    @ID(custom: "id") public var id: ObjectId?
    @Field(key: "phoneNumber") public var phoneNumber: String?
    @Field(key: "email") public var email: String?
    @Field(key: "code") public var code: String
    @Field(key: "expiresAt") public var expiresAt: Date?

    public init() { }

    public init(
        phoneNumber: String? = nil,
        email: String? = nil,
        code: String,
        expiresAt: Date?
    ) {
        self.phoneNumber = phoneNumber
        self.email = email
        self.code = code
        self.expiresAt = expiresAt
    }
}
