import Vapor
import Leaf
import VaporRouting
import AddaSharedModels
import AddaMeRouteHandlers
import AppExtensions

// configures your application
public func configure(_ app: Application) async throws {

    var connectionString: String = ""
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.views.use(.leaf)

    switch app.environment {
    case .development:
        app.apns.configuration = try .init( authenticationMethod: .jwt(
            key: .private(pem: Data(Environment.apnsKey.utf8)),
            keyIdentifier: .init(string: Environment.apnsKeyId),
            teamIdentifier: Environment.apnsTeamId
            ),
            topic: Environment.apnsTopic,
            environment: .sandbox
        )
    case .production:
        app.apns.configuration = try .init( authenticationMethod: .jwt(
            key: .private(pem: Data(Environment.apnsKey.utf8)),
            keyIdentifier: .init(string: Environment.apnsKeyId),
            teamIdentifier: Environment.apnsTeamId
        ),
            topic: Environment.apnsTopic,
            environment: .production
        )
    default:
        break
    }

    app.twilio.configuration = .environment

    app.middleware.use(JWTMiddleware())
    
    app.setupDatabaseConnections(&connectionString)

    try app.initializeMongoDB(connectionString: connectionString)
    try app.databases.use(.mongo(
        connectionString: connectionString
    ), as: .mongo)
    

    // Add HMAC with SHA-256 signer.
    let jwtSecret = Environment.get("JWTS") ?? String.random(length: 64)
    app.jwt.signers.use(.hs256(key: jwtSecret))

    //  app.logger.logLevel = .trace

    // Encoder & Decoder
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    let host = "0.0.0.0"
    var port = 6060
    
    // Configure custom hostname.
    switch app.environment {
    case .production:
        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = 8080
        port = 8080
    case .staging:
        app.http.server.configuration.port = 8081
        app.http.server.configuration.hostname = "0.0.0.0"
        port = 8081
    case .development:
        app.http.server.configuration.port = 8080
        app.http.server.configuration.hostname = "0.0.0.0"
        port = 8080
    default:
        app.http.server.configuration.port = 8080
        app.http.server.configuration.hostname = "0.0.0.0"
        port = 8080
    }
    
    
    try routes(app)
    let baseURL = "http://\(host):\(port)"
    
    app.router = siteRouter
        .baseURL(baseURL)
        .eraseToAnyParserPrinter()
    
    app.mount(app.router, use: siteHandler)
    
}


extension Application {
    private static let runQueue = DispatchQueue(label: "Run")

    /// We need to avoid blocking the main thread, so spin this off to a separate queue
    public func customRun() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Self.runQueue.async { [self] in
                do {
                    try run()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
