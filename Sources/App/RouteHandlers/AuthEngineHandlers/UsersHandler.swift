
import Vapor
import MongoKitten
import Fluent
import URLRouting
import AddaSharedModels
import BSON

public func usersHandler(
    request: Request,
    route: UsersRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .user(id: let id, route: let userRoute):
        return try await userHandler(request: request, usersId: id, route: userRoute)

    case .update(input: let input):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }
        
        let data = input
        guard  currentUserID == input.id  else {
            throw Abort(.notFound, reason: "userId not found!")
        }

        let encoder = BSONEncoder()
        let encoded: Document = try encoder.encode(input)
        let updator: Document = ["$set": encoded]

        _ = try await request.mongoDB[UserModel.schema]
            .updateOne(where: "_id" == input.id, to: updator)
            .get()
        return data
    }
}
