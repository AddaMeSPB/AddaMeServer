import Vapor
import Fluent
import FluentMongoDriver

public final class BlockListModel: Model {

    public static var schema = "block_lists"

    public init() {}

    public init(id: ObjectId?, ownerID: ObjectId, blockUserIDs: Set<[ObjectId]>) {
        self.id = id
        self.ownerID = ownerID
        self.blockUserIDs = blockUserIDs
    }

    @ID(custom: "id") public var id: ObjectId?
    @Field(key: "ownerId") public var ownerID: ObjectId
    @Field(key: "blockUserIds") public var blockUserIDs: Set<[ObjectId]>

    @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

}

import AddaSharedModels

extension BlockListModel: Content {
    public var response: BlockListInoutPut {
        .init(
            id: id,
            userID: ownerID,
            blockUserIDs: blockUserIDs,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }
}
