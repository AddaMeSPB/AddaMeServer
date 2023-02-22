import Vapor
import Queues
import QueuesRedisDriver

func queues(_ app: Application) throws {
    // MARK: Queues Configuration

    let environmentNameUppercased = app.environment.name.uppercased()
    let redisConfiguration = try RedisConfiguration(
        url: Environment.get("REDIS_URL_\(environmentNameUppercased)") ?? "redis://127.0.0.1:6379",
        pool: RedisConfiguration.PoolOptions(connectionRetryTimeout: .minutes(1))
      )

    app.redis.configuration = redisConfiguration
    app.queues.use(.redis(redisConfiguration))


    // MARK: Jobs
    app.queues.add(EmailJob())

    // MARK: Start Queue process jobs
    try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()
}
