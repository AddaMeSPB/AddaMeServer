import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

public final class UserModel: Model, Hashable {

  public static var schema = "users"

  public init() {}

    public init(
        id: ObjectId? = nil,
        fullName: String? = nil,
        avatar: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        contacts: [ContactModel] = [],
        devices: [DeviceModel] = [],
        events: [HangoutEventModel] = [],
        senders: [MessageModel] = [],
        recipients: [MessageModel] = [],
        attachments: [AttachmentModel] = []
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.$contacts.value = contacts
        self.$devices.value = devices
        self.$events.value = events
        self.$senders.value = senders
        self.$recipients.value = recipients
        self.$attachments.value = attachments
    }

    public init(
        id: ObjectId? = nil,
        fullName: String,
        language: UserLanguage,
        role: UserRole = .basic,
        isEmailVerified: Bool = false,
        phoneNumber: String? = nil,
        email: String? = nil,
        passwordHash: String
    ) {
        self.fullName = fullName
        self.language = language
        self.role = role
        self.isEmailVerified = isEmailVerified
        self.phoneNumber = phoneNumber
        self.email = email
        self.passwordHash = passwordHash
    }

  @ID(custom: "id") public var id: ObjectId?

  @OptionalField(key: "fullName") public var fullName: String?
  @Field(key: "language") public var language: UserLanguage
  @Enum(key: "role") public var role: UserRole
  @Field(key: "isEmailVerified") public var isEmailVerified: Bool

  @OptionalField(key: "email") public var email: String?
  @OptionalField(key: "phoneNumber") public var phoneNumber: String?
  @Field(key: "passwordHash") public var passwordHash: String

  @Children(for: \.$user) public var contacts: [ContactModel]
  @Children(for: \.$user) public var devices: [DeviceModel]
  @Children(for: \.$owner) public var events: [HangoutEventModel]
  @Children(for: \.$sender) public var senders: [MessageModel]
  @Children(for: \.$recipient) public var recipients: [MessageModel]
  @Children(for: \.$user) public var attachments: [AttachmentModel]

  @Siblings(through: UserConversationModel.self, from: \.$member, to: \.$conversation)
  public var memberConversaions: [ConversationModel]

  @Siblings(through: UserConversationModel.self, from: \.$admin, to: \.$conversation)
  public var adminConversations: [ConversationModel]

  @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
  @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
  @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

}

extension UserModel {
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: UserModel, rhs: UserModel) -> Bool {
      lhs.id == rhs.id
    }
}

extension UserModel {
  public var amConversations: [ConversationModel] {
    return self.adminConversations + self.memberConversaions
  }

  public var response: UserOutput {
      .init(
        id: id!,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber ?? "",
        role: role,
        language: language,
        devices: $devices.value.map { $0.map { $0.res } },
        hangouts: $events.value.map { $0.map { $0.response } },
        attachments: $attachments.value.map { $0.map { $0.response } },
        adminsConversations: $adminConversations.value.map { $0.map { $0.response } },
        membersConversaions: $memberConversaions.value.map { $0.map { $0.response } },
        url: .home,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt
      )
  }
}

extension UserOutput: Content {}

extension UserModel {
    /// User map get
    /// - Returns: it return user without eager loading
    public func mapGet() -> UserOutput {
        return .init(
            id: id ?? ObjectId(),
            fullName: fullName ?? "unknown",
            email: email, phoneNumber: phoneNumber,
            role: role,
            language: language,
            url: .home,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    public func mapGetPublic() -> UserGetPublicObject {
        return .init(id: id, fullName: fullName ?? "unknown", role: role, language: language)
    }
}

