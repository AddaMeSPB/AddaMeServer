@testable import App
import XCTVapor
import AddaSharedModels

class AppTests: XCTestCase {
    var app: Application!
    public var token = ""

    func createTestApp() async throws -> Application {
        app = Application(.testing)
        try await configure(app)
        app.databases.reinitialize()
        return app
    }

    override func tearDown() async throws {
        try await super.tearDown()
        try await app!.autoRevert().get()
        try await app!.autoMigrate().get()

    }

//    func getAccessToken() async throws -> UserModel {
//
//        let user = try await UserModel.create(phoneNumber: "+79218821211", database: app.db)
//
//        let userPayload = try Payload(with: user)
//        let accessToken = try app.jwt.signers.sign(userPayload)
//        token = accessToken
//        return user
//    }
}
