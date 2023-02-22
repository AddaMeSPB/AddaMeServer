@testable import App
import XCTVapor
import XCTest
import BSON
import VaporRouting
import AddaSharedModels

extension VerifyEmailInput: Content {}

final class AuthTests: AppTests {

    var attemptId: ObjectId? = nil
    let niceName = "Saroar"
    let email = "saroar9@gmail.com"


    func testEmialOTPLogin() async throws {
        app = try await createTestApp()

        let emailLoginInput = EmailLoginInput(email: "saroar9@gmail.com")

        app.mount(siteRouter) { request, route in
            switch route {
            case .authEngine(.authentication(.loginViaEmail(emailLoginInput))):
                return ""
            default:
                return Response(status: .badRequest)
            }
        }

        try await app.test(
            .POST,
            "v1/auth/otp_login_email",
            beforeRequest: { req in
                try req.content.encode(emailLoginInput)
            },

            afterResponse: { response in
                XCTAssertEqual(response.status, .ok)

                do {
                    let responseDecode = try response.content.decode(EmailLoginOutput.self)
                    attemptId = responseDecode.attemptId
                    XCTAssertEqual(email, responseDecode.email)

                    /// this is not right i will separate each func
                    try await verifyEmail()
                } catch {
                    print(#line, error)
                }
            }
        )
    }

    func verifyEmail() async throws {
        app = try await createTestApp()

        guard let attemptId = attemptId else {
            throw "cant find attemptId"
        }

        let verifyEmailInput = VerifyEmailInput(niceName: niceName, email: email, attemptId: attemptId, code: "336699")

        app.mount(siteRouter) { request, route in
            switch route {
            case .authEngine(.authentication(.verifyEmail(verifyEmailInput))):
                return ""
            default:
                return Response(status: .badRequest)
            }
        }

        try app.test(
            .POST,
            "v1/auth/verify_otp_email",
            beforeRequest: { req in
                try req.content.encode(verifyEmailInput)
            },

            afterResponse: { response in
                XCTAssertEqual(response.status, .ok)

                do {
                    let responseDecode = try response.content.decode(SuccessfulLoginResponse.self)

                    XCTAssertNotNil(responseDecode.user.id)
                    XCTAssertNotNil(responseDecode.access.accessToken)
                    XCTAssertNotNil(responseDecode.access.refreshToken)

                } catch {
                    print(#line, error)
                }
            }
        )
    }
}
