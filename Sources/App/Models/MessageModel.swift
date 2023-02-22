import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

public final class MessageModel: Model {

  public static var schema = "messages"

  public init() {}

  public init(
    _ messageItem: MessageItem,
    senderId: UserModel.IDValue? = nil,
    receipientId: UserModel.IDValue? = nil
  ) {
    self.$conversation.id =  messageItem.conversationId
    self.$sender.id = messageItem.sender?.id
    self.$recipient.id = messageItem.recipient?.id
    self.messageBody = messageItem.messageBody
    self.messageType = messageItem.messageType
    self.isRead = messageItem.isRead ?? false
    self.isDelivered = messageItem.isDelivered ?? false
  }

  @ID(custom: "id") public var id: ObjectId?
  @Field(key: "messageBody") public var messageBody: String
  @Field(key: "messageType") public var messageType: MessageType
  @Field(key: "isRead") public var isRead: Bool
  @Field(key: "isDelivered") public var isDelivered: Bool

  @Parent(key: "conversationId") public var conversation: ConversationModel
  @OptionalParent(key: "senderId") public var sender: UserModel?
  @OptionalParent(key: "recipientId") public var recipient: UserModel?

  @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
  @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
  @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

}

extension MessageModel {

  public var response: MessageItem {
      .init(
        id: id ?? ObjectId(),
        conversationId: $conversation.id,
        messageBody: messageBody,
        messageType: messageType,
        isRead: isRead,
        isDelivered: isDelivered,
        sender: sender?.response,
        recipient: recipient?.response,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt
      )
  }
}
