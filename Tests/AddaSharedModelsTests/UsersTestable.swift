#if os(macOS) || os(Linux)
@testable import AddaSharedModels
import Fluent

extension UserModel {
    public static func create(
        email: String,
        fullName: String,
        database: Database
    ) throws -> UserModel {
        let user = UserModel(fullName: fullName, email: email)
        try user.save(on: database).wait()
        return user
    }
}
#endif

