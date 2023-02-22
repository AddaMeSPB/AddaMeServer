import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

public final class ContactModel: Model {

  public static var schema = "contacts"

  public init() {}

  public init(
    id: ObjectId? = nil,
    phoneNumber: String,
    identifier: String,
    fullName: String? = nil,
    avatar: String? = nil,
    isRegister: Bool? = false,
    userId: UserModel.IDValue
  ) {
    self.id = id
    self.phoneNumber = phoneNumber
    self.identifier = identifier
    self.avatar = avatar
    self.fullName = fullName
    self.isRegister = isRegister
    self.$user.id = userId
  }

  @ID(custom: "id") public var id: ObjectId?
  @Field(key: "phoneNumber") public var phoneNumber: String
  @Field(key: "identifier") public var identifier: String
  @Field(key: "fullName") public var fullName: String?
  @Field(key: "avatar") public var avatar: String?
  @Field(key: "isRegister") public var isRegister: Bool?
  @Parent(key: "userId") public var user: UserModel

  @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
  @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
  @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

}

extension ContactModel: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(phoneNumber)
    hasher.combine(isRegister)
  }

  public static func ==(lhs: ContactModel, rhs: ContactModel) -> Bool {
    return lhs.phoneNumber == rhs.phoneNumber && lhs.isRegister == rhs.isRegister
  }
}

//extension ContactModel {
//    public var response: ContactOutPut { .init(self) }
//}
//
//extension ContactOutPut {
//    public init(_ contact: ContactModel) {
//      self.id = contact.id ?? ObjectId()
//      self.identifier = contact.identifier
//      self.phoneNumber = contact.phoneNumber
//      self.fullName = contact.fullName
//      self.avatar = contact.avatar
//      self.isRegister = contact.isRegister
//      self.userId = contact.$user.id
//    }
//}
