import Vapor
import VaporRouting
import AddaSharedModels

public func eventEngineHandler(
    request: Request,
    route: EventEngineRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .categories(let route):
        return try await categoriesHandler(request: request, route: route)
    case let .events(route):
        return try await eventsHandler(request: request, route: route)
    }
}

