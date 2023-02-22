import Vapor

extension Request {
	// MARK: Repositories
	var users: UserRepository { application.repositories.users.for(self) }
	var refreshTokens: RefreshTokenRepository { application.repositories.refreshTokens.for(self) }
	var emailTokens: EmailTokenRepository { application.repositories.emailTokens.for(self) }
	var passwordTokens: PasswordTokenRepository { application.repositories.passwordTokens.for(self) }
//	 var email: EmailVerifier { application.emailVerifiers.verifier.for(self) }
}

//extension Request {
//	func getPayloadFromToken() -> Response {
//		do {
//			let jwt = try self.jwt.verify(as: Payload.self)
//			globalUser = jwt.user
//		} catch  {
//			return self.redirect(to: "auth/login")
//		}
//	}
//}
