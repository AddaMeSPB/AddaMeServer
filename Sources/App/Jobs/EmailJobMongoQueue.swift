import Vapor
import Mailgun
import MongoQueue

struct EmailJobMongoQueue: RecurringTask {

    var payload: EmailPayload
    var vCodeAttempt: VerificationCodeAttempt

    // The date this task should be executed at earliest
    // We default to one week from 'now'
    var initialTaskExecutionDate: Date { Date() }

    // We can use any execution context. This context is provided on registration, and the job can have access to it to do 'the work'
    // For example, if your job sends email, pass it a handle to the email client
    typealias ExecutionContext = Application

    // Ensures only one user engagement prompt exists per user
    var uniqueTaskKey: String { vCodeAttempt.id!.hexString } ///: Fixed OPS so stupid please fixed me 

    // The amount of time we expect this task to take if it's very slow
    // This is optional, and has a sensible default. Note; it will not be the task's actual deadline.
    // Instead, the task will be killed if worker executing this task goes offline unexpectedly
    // There's a mechanism in MongoQueue to detect a stale or dead task worker
    var maxTaskDuration: TimeInterval { 60 }

    // This job has a low priority. Some other jobs may be done first if there's a contest for job queue time
    var priority: TaskPriority { .higher }

    // Execute the task. In our case, we check their last login date
    func execute(withContext context: ExecutionContext) async throws {
        let mailgunMessage = MailgunTemplateMessage(
            from: context.config.noReplyEmail,
            to: payload.recipient,
            subject: payload.email.subject,
            template: payload.email.templateName,
            templateData: payload.email.templateData
        )

        do {
           _ = try await context.mailgun().send(mailgunMessage).get()
        } catch {
            print("EmailJobMongoQueue ExecutionContext: \(error)")
        }
    }

    // When to send the next reminder to the user
    // If `nil` is returned, this job will never run again
    func getNextRecurringTaskDate(_ context: ExecutionContext) async throws -> Date? {
        return nil
    }

    // If we failed to run the job for whatever reason (SMTP issue, database issue or otherwise)
    func onExecutionFailure(failureContext: QueuedTaskFailure<ExecutionContext>) async throws -> TaskExecutionFailureAction {
        // Retry in 1 hour, `nil` for maxAttempts means we never stop retrying
        print("QueuedTaskFailure: \(failureContext.error)")
        return .retryAfter(3600, maxAttempts: nil)
    }
}

