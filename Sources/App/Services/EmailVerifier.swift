import Vapor
import Queues
import AddaSharedModels

struct EmailVerifier {
	let emailTokenRepository: EmailTokenRepository
	let config: AppConfig
	let queue: Queue
	let eventLoop: EventLoop
	let generator: RandomGenerator

	func verify(for user: UserModel) async throws {
        guard let userEmail = user.email else {
            throw Abort(.notFound, reason: "email is missing")
        }

		let token = generator.generate(bits: 256)
		let emailToken = try EmailToken(userID: user.requireID(), token: SHA256.hash(token))
		let verifyUrl = url(token: token)
		try await emailTokenRepository.create(emailToken)
		try await self.queue.dispatch(
            EmailJob.self,
            .init(VerificationEmail(verifyUrl: verifyUrl), to: userEmail)
        )
	}

    func verifyOTPEmail(for userEmail: String, msg: String) async throws {

        var verificationEmail = VerificationEmail.init(verifyUrl: msg)
        verificationEmail.subject = "Addame2 Verification Code"
        verificationEmail.templateName = "addame_otp"

        try await self.queue.dispatch(
            EmailJob.self,
            .init(verificationEmail, to: userEmail)
        )
    }

	private func url(token: String) -> String {
		#"\#(config.apiURL)/api/auth/email-verification?token=\#(token)"#
	}
}

extension Application {
	var emailVerifier: EmailVerifier {
		.init(emailTokenRepository: self.repositories.emailTokens,
			  config: self.config, queue: self.queues.queue,
			  eventLoop: eventLoopGroup.next(), generator: self.random)
	}
}

extension Request {
	var emailVerifier: EmailVerifier {
		.init(emailTokenRepository: self.emailTokens,
			  config: application.config, queue: self.queue, eventLoop: eventLoop,
			  generator: self.application.random)
	}
}
