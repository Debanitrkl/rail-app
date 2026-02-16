import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Job } from 'bullmq';
import {
  QueueService,
  QueueName,
  NotificationDispatchJob,
} from '../queue.service';

@Injectable()
export class NotificationDispatchProcessor implements OnModuleInit {
  private readonly logger = new Logger(NotificationDispatchProcessor.name);

  constructor(private readonly queueService: QueueService) {}

  onModuleInit() {
    this.queueService.registerWorker(
      QueueName.NOTIFICATION_DISPATCH,
      this.process.bind(this),
    );
    this.logger.log('Notification dispatch processor registered');
  }

  async process(job: Job<NotificationDispatchJob>): Promise<void> {
    const { userId, type, title, body, data } = job.data;
    this.logger.debug(
      `Dispatching ${type} notification to user ${userId}: ${title}`,
    );

    try {
      // In production, this would use APNs/FCM to send push notifications.
      // For now, log the notification and store it.
      this.logger.log(
        `Notification sent to ${userId}: [${type}] ${title} - ${body}`,
      );

      // Here you would:
      // 1. Look up user's device tokens from the database
      // 2. Send APNs push notification
      // 3. Track delivery status

      // Simulate processing
      await new Promise((resolve) => setTimeout(resolve, 100));
    } catch (error) {
      this.logger.error(
        `Failed to dispatch notification to user ${userId}`,
        error,
      );
      throw error;
    }
  }
}
