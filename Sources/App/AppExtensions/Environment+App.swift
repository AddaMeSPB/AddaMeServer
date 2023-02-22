
import Vapor

extension Environment {

    // For Apple Login
    static public let siwaId = Self.get("SIWA_ID")!
    static public let siwaAppId = Self.get("SIWA_APP_ID")!
    static public let siwaRedirectUrl = Self.get("SIWA_REDIRECT_URL")!
    static public let siwaTeamId = Self.get("SIWA_TEAM_ID")!
    static public let siwaJWKId = Self.get("SIWA_JWK_ID")!
    static public let siwaKey = Self.get("SIWA_KEY")!.base64Decoded()!
    static public let apnsKeyId = Self.get("APNS_KEY_ID")!
    static public let apnsTeamId = Self.get("APNS_TEAM_ID")!
    static public let apnsTopic = Self.get("APNS_TOPIC")!
    static public let apnsKey = Self.get("APNS_PRIVATE_KEY")!.base64Decoded()!

    //
    static public var staging: Environment { .init(name: "staging") }
}
