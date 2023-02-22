import Vapor
import Fluent
import FluentMongoDriver
import AddaSharedModels

public final class AttachmentModel: Model {
    
    public static var schema = "attachments"
    
    public init() {}
    
    public init(id: ObjectId? = nil, type: AttachmentType = .image, userId: UserModel.IDValue?, imageUrlString: String? = nil, audioUrlString: String? = nil, videoUrlString: String? = nil, fileUrlString: String? = nil)  {
        self.id = id
        self.type = type
        self.$user.id = userId
        self.imageUrlString = imageUrlString
        self.audioUrlString = audioUrlString
        self.videoUrlString = videoUrlString
        self.fileUrlString = fileUrlString
    }
    
    @ID(custom: "id") public var id: ObjectId?
    @Field(key: "type") public var type: AttachmentType
    
    @OptionalParent(key: "userId") public var user: UserModel?
    
    @OptionalField(key: "imageUrlString") public var imageUrlString: String?
    @OptionalField(key: "audioUrlString") public var audioUrlString: String?
    @OptionalField(key: "videoUrlString") public var videoUrlString: String?
    @OptionalField(key: "fileUrlString") public var fileUrlString: String?
    
    @Timestamp(key: "createdAt", on: .create) public var createdAt: Date?
    @Timestamp(key: "updatedAt", on: .update) public var updatedAt: Date?
    @Timestamp(key: "deletedAt", on: .delete) public var deletedAt: Date?
    
}

extension AttachmentModel {
    public var response: AttachmentInOutPut {
        return AttachmentInOutPut(
            id: id,
            type: type,
            userId: $user.id,
            imageUrlString: imageUrlString,
            audioUrlString: audioUrlString,
            videoUrlString: videoUrlString,
            fileUrlString: fileUrlString,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )
    }

}

extension AttachmentInOutPut: Content {}
