import Mailgun
import Vapor

extension MailgunDomain {
    static var sandbox: MailgunDomain {
      .init( "sandbox85d89c55d2ae4a3b8aaeca56b3a025c5.mailgun.org", .us)
    }
    
    static var production: MailgunDomain { .init("addame.com", .eu)}
}

