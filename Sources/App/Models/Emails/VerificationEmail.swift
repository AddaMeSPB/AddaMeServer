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

struct OTPEmail: Email {

  let templateName: String
  let name: String
  let bodyWithOtp: String
  let duration: String
  let subject: String

  var templateData: [String : String] {
    [
      "name": name,
      "otp": bodyWithOtp,
      "duration": duration
    ]
  }

  init(
    templateName: String = "email_verification",
    name: String,
    bodyWithOtp: String,
    duration: String,
    subject: String = "Please verify your email"
  ) {
    self.templateName = templateName
    self.name = name
    self.bodyWithOtp = bodyWithOtp
    self.duration = duration
    self.subject = subject

  }
}
