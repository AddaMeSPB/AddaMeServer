import Vapor
import Fluent
import MongoKitten

protocol PasswordTokenRepository: Repository {
	func find(userID: ObjectId) async throws -> PasswordToken?
	func find(token: String) async throws -> PasswordToken?
	func count() async throws -> Int
	func create(_ passwordToken: PasswordToken) async throws
	func delete(_ passwordToken: PasswordToken) async throws
	func delete(for userID: ObjectId) async throws
}

struct DatabasePasswordTokenRepository: PasswordTokenRepository, DatabaseRepository {
	var database: Database

	func find(userID: ObjectId) async throws -> PasswordToken? {
		try await PasswordToken.query(on: database)
			.filter(\.$user.$id == userID)
			.first()
			.get()
	}

	func find(token: String) async throws -> PasswordToken? {
		try await PasswordToken.query(on: database)
			.filter(\.$token == token)
			.first()
			.get()
	}

	func count() async throws -> Int {
		try await PasswordToken.query(on: database).count()
	}

	func create(_ passwordToken: PasswordToken) async throws {
		try await passwordToken.create(on: database).get()
	}

	func delete(_ passwordToken: PasswordToken) async throws {
		try await passwordToken.delete(on: database).get()
	}

	func delete(for userID: ObjectId) async throws {
		try await PasswordToken.query(on: database)
			.filter(\.$user.$id == userID)
			.delete()
			.get()
	}
}

extension Application.Repositories {
	var passwordTokens: PasswordTokenRepository {
		guard let factory = storage.makePasswordTokenRepository else {
			fatalError("PasswordToken repository not configured, use: app.repositories.use")
		}
		return factory(app)
	}

	func use(_ make: @escaping (Application) -> (PasswordTokenRepository)) {
		storage.makePasswordTokenRepository = make
	}
}
