import Vapor
import Fluent
import MongoKitten
import AddaSharedModels

protocol UserRepository: Repository {
	func create(_ user: UserModel) async throws
	func delete(id: ObjectId) -> EventLoopFuture<Void>
	func all() async throws -> [UserModel]
	func find(id: ObjectId?) async throws -> UserModel?
	func find(email: String) async throws -> UserModel?
    func find(phoneNumber: String) async throws -> UserModel?
	func set<Field>(_ field: KeyPath<UserModel, Field>, to value: Field.Value, for userID: ObjectId) async throws -> Void where Field: QueryableProperty, Field.Model == UserModel
	func count() -> EventLoopFuture<Int>
}

struct DatabaseUserRepository: UserRepository, DatabaseRepository {
	let database: Database

	func create(_ user: UserModel) async throws {
		try await user.create(on: database)
	}

	func delete(id: ObjectId) -> EventLoopFuture<Void> {
		return UserModel.query(on: database)
			.filter(\.$id == id)
			.delete()
	}

	func all()  async throws -> [UserModel] {
        try await UserModel.query(on: database).sort(\.$fullName).all().get()
	}

	func find(id: ObjectId?) async throws -> UserModel? {
		try await UserModel.find(id, on: database)
	}

    func find(phoneNumber: String) async throws -> UserModel? {
        try await UserModel.query(on: database)
            .filter(\.$phoneNumber == phoneNumber)
            .first()
            .get()
    }

	func find(email: String) async throws -> UserModel? {
		try await UserModel.query(on: database)
			.filter(\.$email == email)
			.first()
			.get()
	}

	func set<Field>(_ field: KeyPath<UserModel, Field>, to value: Field.Value, for userID: ObjectId) async throws -> Void
	where Field: QueryableProperty, Field.Model == UserModel
	{
		try await UserModel.query(on: database)
			.filter(\.$id == userID)
			.set(field, to: value)
			.update()

	}

	func count() -> EventLoopFuture<Int> {
		return UserModel.query(on: database).count()
	}
}

extension Application.Repositories {
	var users: UserRepository {
		guard let storage = storage.makeUserRepository else {
			fatalError("UserRepository not configured, use: app.userRepository.use()")
		}

		return storage(app)
	}

	func use(_ make: @escaping (Application) -> (UserRepository)) {
		storage.makeUserRepository = make
	}
}
