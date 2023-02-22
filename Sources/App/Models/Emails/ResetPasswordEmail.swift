import Vapor

struct ResetPasswordEmail: Email {
    var templateName: String = "resetPassword"
    var templateData: [String : String] {
        ["resetUrl": resetURL]
    }
    var subject: String {
        "Reset your password"
    }
    
    let resetURL: String
    
    init(resetURL: String) {
        self.resetURL = resetURL
    }
}

