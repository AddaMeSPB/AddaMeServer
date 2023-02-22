
import Vapor
import Fluent
import AddaSharedModels
import VaporRouting
import BSON

public func authEngineHandler(
    request: Request,
    route: AuthEngineRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case let .users(usersRoute):
        return try await usersHandler(request: request, route: usersRoute)
    case let .contacts(contactsRoute):
        return try await contactsHandler(request: request, route: contactsRoute)
    case let .devices(devicesRoute):
        return try await devicesHandler(request: request, route: devicesRoute)
    case let .authentication(authenticationRoute):
        return try await authenticationHandler(request: request, route: authenticationRoute)
    }
}
