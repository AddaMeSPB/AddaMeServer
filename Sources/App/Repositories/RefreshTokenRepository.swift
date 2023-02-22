import Vapor
import Fluent
import MongoKitten

protocol RefreshTokenRepository: Repository {
	func create(_ token: RefreshTokenModel) async throws -> Void
	func find(id: ObjectId?) async throws -> RefreshTokenModel?
	func find(token: String) async throws -> RefreshTokenModel?
	func delete(_ token: RefreshTokenModel) async throws -> Void
	func count() async throws -> Int
	func delete(for userID: ObjectId) async throws -> Void
}

struct DatabaseRefreshTokenRepository: RefreshTokenRepository, DatabaseRepository {
	let database: Database

	func create(_ token: RefreshTokenModel) async throws {
		try await token.create(on: database)
	}

	func find(id: ObjectId?) async throws -> RefreshTokenModel? {
		try await RefreshTokenModel.find(id, on: database)
	}

	func find(token: String) async throws -> RefreshTokenModel? {
		try await RefreshTokenModel.query(on: database)
			.filter(\.$token == token)
			.first()
			.get()
	}

	func delete(_ token: RefreshTokenModel) async throws {
		try await token.delete(on: database)
	}

	func count() async throws -> Int {
		try await RefreshTokenModel.query(on: database)
			.count()
			.get()
	}

	func delete(for userID: ObjectId) async throws {
		try await RefreshTokenModel.query(on: database)
			.filter(\.$user.$id == userID)
			.delete()
			.get()
	}
}

extension Application.Repositories {
	var refreshTokens: RefreshTokenRepository {
		guard let factory = storage.makeRefreshTokenRepository else {
			fatalError("RefreshToken repository not configured, use: app.repositories.use")
		}
		return factory(app)
	}

	func use(_ make: @escaping (Application) -> (RefreshTokenRepository)) {
		storage.makeRefreshTokenRepository = make
	}
}
