import Mailgun
import Vapor

extension MailgunDomain {
    static var sandbox: MailgunDomain {
      .init( Environment.get("MAILGUN_DOMAIN") ?? "", .us)
    }
    static var productoin: MailgunDomain { .init("word.justcal.me", .eu)}
}
