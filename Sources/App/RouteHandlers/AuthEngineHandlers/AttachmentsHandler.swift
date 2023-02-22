import Vapor
import AddaSharedModels
import Fluent
import URLRouting
import BSON

public func attachmentsHandler(
    request: Request,
    route: AttachmentsRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .create(input: let input):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        let inputData = input
        
        let attachment = AttachmentModel(
            type: inputData.type,
            userId: inputData.userId,
            imageUrlString: inputData.imageUrlString,
            audioUrlString: inputData.audioUrlString,
            videoUrlString: inputData.videoUrlString,
            fileUrlString: inputData.fileUrlString)
        
        try await attachment.save(on: request.db).get()
        return  attachment.response
        
        // have to delete
    case .findWithOwnerId:
        if request.loggedIn == false { throw Abort(.unauthorized) }

        guard let ownerId = request.payload.user.id else {
            throw Abort(.notFound, reason: "User not found!")
        }
        
        let attactments = try await AttachmentModel.query(on: request.db)
            .filter(\.$user.$id == ownerId)
            .all()
            .get()
        
        return attactments.map { $0.response }

    case let .attachment(id: id, attachmentRoute):
        return try await attachmentHandler(id: id, request: request, route: attachmentRoute)
    }
}

public func attachmentHandler(
    id: String,
    request: Request,
    route: AttachmentRoute
) async throws -> AsyncResponseEncodable {
    switch route {

    case .delete:
        if request.loggedIn == false { throw Abort(.unauthorized) }

        guard let ownerId = request.payload.user.id else {
            throw Abort(.notFound, reason: "User not found!")
        }

        guard let id = ObjectId(id) else {
            throw Abort(.notFound, reason: "Attachment id is not found!")
        }

        guard let attachment = try await AttachmentModel.query(on: request.db)
            .filter(\.$id == id)
            .filter(\.$user.$id == ownerId)
            .first()
            .get()
        else {
            throw Abort(.notFound, reason: "No Attachment. found! by ID \(id)")
        }

        try await attachment.delete(on: request.db).get()
        return HTTPStatus.ok
    }
}


