import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { BlacklistService } from '../black-list/black-list.service';
import { RefreshTokenService } from '../refresh-token/refresh-token.service';

@Injectable()
export class TasksService {
  constructor(
    private readonly blacklistService: BlacklistService,
    private readonly refreshTokenService: RefreshTokenService,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async cleanupBlacklist(): Promise<void> {
    await this.blacklistService.cleanupExpired();
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async cleanupRefreshTokens(): Promise<void> {
    await this.refreshTokenService.cleanupExpired();
  }
}
