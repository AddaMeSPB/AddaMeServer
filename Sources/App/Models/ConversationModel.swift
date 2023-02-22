import Vapor
import Fluent
import FluentKit
import FluentMongoDriver
import AddaSharedModels

public final class ConversationModel: Model {

    public static var schema = "conversations"

    @ID(custom: "id") public var id: ObjectId?
    @Field(key: "title") public var title: String
    @Field(key: "type") public var type: ConversationType

    @Children(for: \.$conversation) public var events: [HangoutEventModel]
    @Children(for: \.$conversation) public var messages: [MessageModel]
    @OptionalField(key: "lastMessage") public var lastMessage: MessageModel?

    @Siblings(through: UserConversationModel.self, from: \.$conversation, to: \.$member)
    public var members: [UserModel]

    @Siblings(through: UserConversationModel.self, from: \.$conversation, to: \.$admin)
    public var admins: [UserModel]

    @Timestamp(key: "createdAt", on: TimestampTrigger.create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: TimestampTrigger.update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: TimestampTrigger.delete) public var deletedAt: Date?

    public init() {}

    public init(
        id: ObjectId? = nil,
        title: String,
        lastMessage: MessageModel? = nil,
        type: ConversationType
    ) {
        self.title = title
        self.type = type
        self.lastMessage = lastMessage
    }

}

extension ConversationModel {
    public var response: ConversationOutPut {
        .init(
            id: id ?? ObjectId(),
            title: title,
            type: type,

            admins: admins.map { $0.response },
            members: members.map { $0.response },

            lastMessage: lastMessage?.response,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            deletedAt: deletedAt
        )
    }
}
