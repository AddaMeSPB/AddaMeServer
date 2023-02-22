import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

public final class UserConversationModel: Model {
    public static let schema = "user_conversation_pivot"

    @ID(custom: "id") public var id: ObjectId?

    //@Parent(key: "user_id") var user: User
    @Parent(key: "memberId") public var member: UserModel
    @Parent(key: "adminId") public var admin: UserModel
    @Parent(key: "conversationId")  public var conversation: ConversationModel

    @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

    public init() { }

    public init(
        id: ObjectId? = nil,
        member: UserModel,
        admin: UserModel,
        conversation: ConversationModel
    ) throws {
        self.id = id
        self.$member.id = try member.requireID()
        self.$admin.id = try admin.requireID()
        self.$conversation.id = try conversation.requireID()
    }
}

extension UserConversationModel {
    public func title(currentId: ObjectId) -> String {
        if conversation.type == .oneToOne {
            return member.id == currentId
            ? member.fullName ?? ""
            : member.fullName ?? ""
        } else {
            return conversation.title
        }
    }
}
