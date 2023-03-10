
import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

// `type` ENUM('APPLE') NOT NULL
public final class DeviceModel: Model {

    public static var schema = "devices"

    public init() {}

    public init(
        id: ObjectId? = nil,
        identifierForVendor: String? = nil,
        name: String,
        model: String? = nil,
        osVersion: String? = nil,
        pushToken: String,
        voipToken: String,
        userId: UserModel.IDValue? = nil
    ) {
        self.id = id
        self.identifierForVendor = identifierForVendor
        self.name = name
        self.model = model
        self.osVersion = osVersion
        self.pushToken = pushToken
        self.voipToken = voipToken
        self.$user.id = userId
    }

    @ID(custom: "id") public var id: ObjectId?

    @Field(key: "identifierForVendor") public var identifierForVendor: String?
    @Field(key: "name") public var name: String
    @OptionalField(key: "model") public var model: String?
    @OptionalField(key: "osVersion") public var osVersion: String?
    @Field(key: "pushToken") public var pushToken: String
    @Field(key: "voipToken") public var voipToken: String

    @OptionalParent(key: "ownerId") public var user: UserModel?

    @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

}



extension DeviceModel {

    public var res: DeviceInOutPut {
        .init(
            id: id,
            ownerId: $user.id,
            identifierForVendor: identifierForVendor,
            name: name,
            model: model,
            osVersion: osVersion,
            pushToken: pushToken,
            voipToken: voipToken,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

    public func update(_ input: DeviceInOutPut) async throws {
        self.$user.id = input.ownerId
        self.identifierForVendor = input.identifierForVendor
        self.name = input.name
        self.model = input.model
        self.osVersion = input.osVersion
        self.pushToken = input.pushToken
        self.voipToken = input.voipToken
    }

}
