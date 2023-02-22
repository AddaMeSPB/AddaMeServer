import Vapor

struct VerificationEmail: Email {
	var templateName: String = "email_verification"
	let verifyUrl: String

	var subject: String = "Please verify your email"

	var templateData: [String : String] {
		["verifyUrl": verifyUrl]
	}

	init(verifyUrl: String) {
		self.verifyUrl = verifyUrl
	}
}
