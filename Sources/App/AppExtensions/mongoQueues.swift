import Vapor
import MongoQueue

func mongoQueue(_ app: Application) throws {
    app.mongoQueue.registerTask(EmailJobMongoQueue.self, context: app)
    do  {
        try app.mongoQueue.runInBackground()
    } catch {
        app.logger.info("\(error)")
    }

}

