import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

public final class HangoutEventModel: Model {
    public static var schema = "hangouts"

    public init() {}

    public init(
        id: ObjectId? = nil,
        name: String,
        details: String? = nil,
        imageUrl: String? = nil,
        duration: Int,
        distance: Double? = nil,

        isActive: Bool,
        addressName: String,
        geoType: GeoType,
        coordinates: [Double],
        sponsored: Bool? = false,
        overlay: Bool? = false,
        ownerId: UserModel.IDValue,
        conversationsId: ConversationModel.IDValue,
        categoriesId: CategoryModel.IDValue,

        urlString: String
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.imageUrl = imageUrl
        self.duration = duration
        self.distance = distance
        self.isActive = isActive

        // Place information
        self.addressName = addressName
        self.type = geoType
        self.coordinates = coordinates
        self.sponsored = sponsored
        self.overlay = overlay

        self.$owner.id = ownerId
        self.$conversation.id = conversationsId
        self.$category.id = categoriesId

    }

    public init(
        content: EventInput,
        ownerID: ObjectId,
        conversationsID: ObjectId,
        categoriesID: ObjectId
    ) {
        self.name = content.name
        self.details = content.details
        self.imageUrl = content.imageUrl
        self.duration = content.duration
        self.isActive = content.isActive

        // Place information
        self.addressName = content.addressName
        self.type = content.type
        self.coordinates = content.coordinates
        self.sponsored = content.sponsored
        self.overlay = content.overlay

        self.$owner.id = ownerID
        self.$conversation.id = conversationsID
        self.$category.id = categoriesID

    }

    @ID(custom: "id") public var id: ObjectId?
    @Field(key: "name") public var name: String
    @OptionalField(key: "details") public var details: String?
    @OptionalField(key: "imageUrl") public var imageUrl: String?
    @Field(key: "duration") public var duration: Int
    @OptionalField(key: "distance") public var distance: Double?
    @Field(key: "isActive") public var isActive: Bool

    // Place information
    @Field(key: "addressName") public var addressName: String
    @Field(key: "type") public var type: GeoType
    @Field(key: "coordinates") public var coordinates: [Double]
    @OptionalField(key: "sponsored") public var sponsored: Bool?
    @OptionalField(key: "overlay") public var overlay: Bool?

    @Parent(key: "ownerId") public var owner: UserModel
    @Parent(key: "conversationsId") public var conversation: ConversationModel
    @Parent(key: "categoriesId") public var category: CategoryModel

    @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?

}

extension  HangoutEventModel: Equatable {
    public static func == (lhs: HangoutEventModel, rhs: HangoutEventModel) -> Bool {
        return lhs.id == rhs.id && lhs.isActive == rhs.isActive
        && lhs.createdAt == rhs.createdAt
        && lhs.addressName == rhs.addressName
        && rhs.coordinates == rhs.coordinates
    }
}

extension HangoutEventModel {

    public struct Item: Content {
      public init(
        id: ObjectId? = nil, name: String, details: String? = nil,
        imageUrl: String? = nil, duration: Int, distance: Double? = nil, isActive: Bool,
        conversationsId: ObjectId, categoriesId: ObjectId, addressName: String,
        sponsored: Bool? = nil, overlay: Bool? = nil, type: GeoType,
        coordinates: [Double], updatedAt: Date?, createdAt: Date?, deletedAt: Date?
      ) {
        self._id = id
        self.name = name
        self.details = details
        self.imageUrl = imageUrl
        self.duration = duration
        self.distance = distance
        self.isActive = isActive
        self.conversationsId = conversationsId
        self.categoriesId = categoriesId
        self.addressName = addressName
        self.sponsored = sponsored
        self.overlay = overlay
        self.type = type
        self.coordinates = coordinates
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.deletedAt = deletedAt
      }

      public var recreateEventWithSwapCoordinatesForMongoDB: HangoutEventModel.Item {
        .init(id: _id, name: name, details: details, imageUrl: imageUrl, duration: duration, distance: distance, isActive: isActive, conversationsId: conversationsId, categoriesId: categoriesId, addressName: addressName, sponsored: sponsored, overlay: overlay, type: type, coordinates: swapCoordinatesForMongoDB(), updatedAt: updatedAt, createdAt: createdAt, deletedAt: deletedAt)
      }

      public init(_ event: HangoutEventModel) {
        self._id = event.id
        self.name = event.name
        self.details = event.details
        self.imageUrl = event.imageUrl
        self.duration = event.duration
        self.distance = event.distance
        self.isActive = event.isActive
        self.conversationsId = event.$conversation.id
        self.categoriesId = event.$category.id

        // Place information
        self.addressName = event.addressName
        self.type = event.type
        self.coordinates = event.coordinates
        self.sponsored = event.sponsored
        self.overlay = event.overlay

  //      db.events.updateMany({}, [{ $set: { addressName: "", details: "if you want you explain about your event", type: "Point", coordinates: [29.873706166262373, 60.26134045287572], sponsored: false, overlay: false } }])

        self.createdAt = event.createdAt
        self.updatedAt = event.updatedAt
        self.deletedAt = event.deletedAt
      }

      public var _id: ObjectId?
      public var name: String
      public var details: String?
      public var imageUrl: String?
      public var duration: Int
      public let distance: Double?
      public var isActive: Bool
      public var categoriesId: ObjectId
      public var conversationsId: ObjectId

      // Place Information
      public var addressName: String
      public var sponsored: Bool?
      public var overlay: Bool?
      public var type: GeoType
      public var coordinates: [Double]

      public let updatedAt, createdAt, deletedAt: Date?

      public func swapCoordinatesForMongoDB() -> [Double] {
        return [coordinates[1], coordinates[0]]
      }
    }

    public func update(_ input: EventResponse) async throws {
        id = input.id
        name = input.name
        details = input.details
        imageUrl = input.imageUrl
        duration = input.duration
        isActive = input.isActive
        category.id = input.categoriesId
        conversation.id = input.conversationsId
        addressName = input.addressName
        sponsored = input.sponsored
        overlay = input.overlay
        type = input.type
        coordinates = input.coordinates
    }
}

extension HangoutEventModel {
    public var response: EventResponse {
        .init(
            id: id ?? ObjectId(),
            name: name,
            details: details,
            imageUrl: imageUrl,
            duration: duration,
            distance: distance,
            isActive: isActive,
            conversationsId: $conversation.id,
            categoriesId: $category.id,
            ownerId: $owner.id,

            // Place information
            addressName: addressName,
            sponsored: sponsored,
            overlay: overlay,
            type: type,
            coordinates : [coordinates[1], coordinates[0]],
            url: .home,

            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }
}

public struct EventPage: Content {
    /// The page's items. Usually models.
  public let items: [HangoutEventModel.Item]

    /// Metadata containing information about current page, items per page, and total items.
    public let metadata: PageMetadata

    /// Creates a new `Page`.
    public init(items: [HangoutEventModel.Item], metadata: PageMetadata) {
        self.items = items
        self.metadata = metadata
    }
}
