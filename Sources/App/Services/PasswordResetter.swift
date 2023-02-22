import Vapor
import Queues
import AddaSharedModels
import Foundation

struct PasswordResetter {
	let queue: Queue
	let repository: PasswordTokenRepository
	let eventLoop: EventLoop
	let config: AppConfig
	let generator: RandomGenerator

	/// Sends a email to the user with a reset-password URL
    func reset(for user: UserModel) async throws {

        guard let userEmail = user.email else {
            throw Abort(.notFound, reason: "email is missing") //NWError.custom("email is missing", nil)
        }

		let token = generator.generate(bits: 256)
		let resetPasswordToken = try PasswordToken(userID: user.requireID(), token: SHA256.hash(token))
		let url = resetURL(for: token)
		let email = ResetPasswordEmail(resetURL: url)
		try await repository.create(resetPasswordToken)
		try await self.queue.dispatch(EmailJob.self, .init(email, to: userEmail))
	}

	private func resetURL(for token: String) -> String {
		"\(config.frontendURL)/api/auth/reset-password?token=\(token)"
	}
}

extension Request {
	var passwordResetter: PasswordResetter {
		.init(queue: self.queue, repository: self.passwordTokens, eventLoop: self.eventLoop, config: self.application.config, generator: self.application.random)
	}
}
