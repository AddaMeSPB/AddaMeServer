import Vapor
import AddaSharedModels
import VaporRouting

public func siteHandler(
    request: Request,
    route: SiteRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case let .eventEngine(eventEngineRoute):
        return try await eventEngineHandler(request: request, route: eventEngineRoute)
    case let .chatEngine(chatEngineRoute):
        return try await chatEngineHandler(request: request, route: chatEngineRoute)
    case let .authEngine(authRoute):
        return try await authEngineHandler(request: request, route: authRoute)
    case .terms:
        return try await request.view.render("terms")
    case .privacy:
        return try await request.view.render("privacy")
    }
}
