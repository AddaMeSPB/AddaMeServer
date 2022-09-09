import Vapor
import Fluent
import MongoKitten
import Twilio
import JWT
import AddaSharedModels
import MongoKitten
import AppExtensions

extension AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("login", use: beginSMSVerification)
        auth.post("verify_sms", use: validateVerificationCode)
        auth.post("refreshToken", use: refreshAccessToken)
    }
}

final class AuthController {

    private func beginSMSVerification(_ req: Request) throws -> EventLoopFuture<SendUserVerificationResponse> {

        let verification = try req.content.decode(LoginInput.self)

        let phoneNumber = verification.phoneNumber.removingInvalidCharacters
        let code = String.randomDigits(ofLength: 6)
        let message = "Hello there! Your verification code is \(code)"

        guard let SENDER_NUMBER = Environment.get("SENDER_NUMBER") else {
            fatalError("No value was found at the given public key environment 'SENDER_NUMBER'")
        }
        let sms = OutgoingSMS(body: message, from: SENDER_NUMBER, to: phoneNumber)

        req.logger.info("SMS is \(message)")

        switch req.application.environment {
        case .production:
            return req.application.twilio.send(sms)
                .flatMap { success -> EventLoopFuture<SMSVerificationAttempt> in

                    guard success.status != .badRequest else {
                        return req.eventLoop.makeFailedFuture(Abort(.internalServerError, reason: "SMS could not be sent to \(phoneNumber)"))
                    }

                    let smsAttempt = SMSVerificationAttempt(
                        code: code,
                        expiresAt: Date().addingTimeInterval(5.0 * 60.0),
                        phoneNumber: phoneNumber
                    )

                    return smsAttempt.save(on: req.db).map { smsAttempt }
                }
                .map { attempt in
                    let attemptId = try! attempt.requireID()
                    return SendUserVerificationResponse(phoneNumber: phoneNumber, attemptId: attemptId)
                }.hop(to: req.eventLoop)

        case .development:

            let smsAttempt = SMSVerificationAttempt(
                code: "336699",
                expiresAt: Date().addingTimeInterval(5.0 * 60.0),
                phoneNumber: phoneNumber
            )
            _ = smsAttempt.save(on: req.db).map { smsAttempt }

            let attemptId = try! smsAttempt.requireID()
            return req.eventLoop.future(SendUserVerificationResponse(phoneNumber: phoneNumber, attemptId: attemptId) )

        default:
            let smsAttempt = SMSVerificationAttempt(
                code: "336699",
                expiresAt: Date().addingTimeInterval(5.0 * 60.0),
                phoneNumber: phoneNumber
            )
            _ = smsAttempt.save(on: req.db).map { smsAttempt }

            let attemptId = try! smsAttempt.requireID()
            return req.eventLoop.future(SendUserVerificationResponse(phoneNumber: phoneNumber, attemptId: attemptId) )
        }
    }

    private func validateVerificationCode(_ req: Request) async throws -> LoginResponse {
        // 1
        let payload = try req.content.decode(UserVerificationPayload.self)
        let code = payload.code
        let attemptId = payload.attemptId
        let phoneNumber = payload.phoneNumber.removingInvalidCharacters

        guard let attempt = try await SMSVerificationAttempt.query(on: req.db)
            .filter(\.$code == code)
            .filter(\.$phoneNumber == phoneNumber)
            .filter(\.$id == attemptId)
            .first()
            .get()
        else {
            throw Abort(.notFound, reason: "SMSVerificationAttempt not found!")
        }

            guard let expirationDate = attempt.expiresAt else {
                return LoginResponse.init(status: "invalid-code")
            }

            guard expirationDate > Date() else {
                return LoginResponse.init(status: "invalid-code")
            }

        return try await self.verificationResponseForValidUser(with: phoneNumber, on: req)

    }

    private func verificationResponseForValidUser(
        with phoneNumber: String,
        on req: Request) async throws -> LoginResponse {

            let createNewUser = User.init(phoneNumber: phoneNumber)

            if try await findUserResponse(with: phoneNumber, on: req) == nil {
                _ = try await createNewUser.save(on: req.db).get()
            }

            guard let user = try await findUserResponse(with: phoneNumber, on: req) else {
                throw Abort(.notFound, reason: "User not found")
            }

            do {
                let userPayload = Payload(id: user.response.id!, phoneNumber: user.response.phoneNumber)
                let refreshPayload = RefreshToken(user: user)

                let accessToken = try req.application.jwt.signers.sign(userPayload)
                let refreshToken = try req.application.jwt.signers.sign(refreshPayload)

                let access = RefreshTokenResponse(accessToken: accessToken, refreshToken: refreshToken)
                return LoginResponse(status: "ok", user: user.response,  access: access)
            }
            catch {
                throw error
            }

    }


    func findUserResponse(with phoneNumber: String,
                          on req: Request
    ) async throws -> User? {

        try await User.query(on: req.db)
            .with(\.$attachments)
            .filter(\.$phoneNumber == phoneNumber)
            .first()
            .get()
    }

    private func refreshAccessToken(_ req: Request) async throws -> RefreshTokenResponse  {
        let data = try req.content.decode(RefreshTokenInput.self)
        let refreshTokenFromData = data.refreshToken
        let jwtPayload: RefreshToken = try req.application
            .jwt.signers.verify(refreshTokenFromData, as: RefreshToken.self)

        guard let userID = jwtPayload.id else {
            throw Abort(.notFound, reason: "User id missing from RefreshToken")
        }

        guard let user = try await User.query(on: req.db)
            .with(\.$attachments)
            .filter(\.$id == userID)
            .first()
            .get()
        else {
            throw Abort(.notFound, reason: "User not found by id: \(userID) for refresh token")
        }

        let payload = Payload(id: user.id!, phoneNumber: user.phoneNumber)
        let refreshPayload = RefreshToken(user: user)

        do {
            let refreshToken = try req.application.jwt.signers.sign(refreshPayload)
            let payloadString = try req.application.jwt.signers.sign(payload)
            return RefreshTokenResponse(accessToken: payloadString, refreshToken: refreshToken)
        } catch {
            throw Abort(.notFound, reason: "jwt signers error: \(error)")
        }

    }

}


