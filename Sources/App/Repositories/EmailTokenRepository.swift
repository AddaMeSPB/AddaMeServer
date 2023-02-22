import Vapor
import Fluent
import MongoKitten

protocol EmailTokenRepository: Repository {
	func find(token: String) -> EventLoopFuture<EmailToken?>
	func create(_ emailToken: EmailToken) async throws
	func delete(_ emailToken: EmailToken) async throws
	func find(userID: ObjectId) -> EventLoopFuture<EmailToken?>
}

struct DatabaseEmailTokenRepository: EmailTokenRepository, DatabaseRepository {
	let database: Database

	func find(token: String) -> EventLoopFuture<EmailToken?> {
		return EmailToken.query(on: database)
			.filter(\.$token == token)
			.first()
	}

	func create(_ emailToken: EmailToken) async throws {
		try await emailToken.create(on: database).get()
	}

	func delete(_ emailToken: EmailToken) async throws {
		try await emailToken.delete(on: database).get()
	}

	func find(userID: ObjectId) -> EventLoopFuture<EmailToken?> {
		EmailToken.query(on: database)
			.filter(\.$user.$id == userID)
			.first()
	}
}

extension Application.Repositories {
	var emailTokens: EmailTokenRepository {
		guard let factory = storage.makeEmailTokenRepository else {
			fatalError("EmailToken repository not configured, use: app.repositories.use")
		}
		return factory(app)
	}

	func use(_ make: @escaping (Application) -> (EmailTokenRepository)) {
		storage.makeEmailTokenRepository = make
	}
}
