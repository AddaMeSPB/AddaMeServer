
import Vapor
import Fluent
import FluentKit
import FluentMongoDriver
import AddaSharedModels

public final class CategoryModel: Model {

    public static var schema = "categories"
    public init() {}

    public init(
        id: ObjectId? = nil,
        name: String
    ) {
        self.id = id
        self.name = name
    }

    @ID(custom: "id") public var id: ObjectId?
    @Field(key: "name") public var name: String
    @Children(for: \.$category) public var events: [HangoutEventModel]

    @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?
}

extension CategoryModel {
    public var response: CategoryResponse {
        .init(
            id: id ?? ObjectId(),
            name: name,
            url: URL.home
        )
    }
}

extension CategoryModel: Equatable {
    public static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
