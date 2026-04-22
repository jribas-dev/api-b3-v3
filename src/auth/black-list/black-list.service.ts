import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { TokenBlacklist } from './black-list.entity';

@Injectable()
export class BlacklistService {
  constructor(
    @InjectRepository(TokenBlacklist)
    private blacklistRepo: Repository<TokenBlacklist>,
  ) {}

  async addToken(token: string, expiresAt: Date) {
    const blacklisted = this.blacklistRepo.create({ token, expiresAt });
    return this.blacklistRepo.save(blacklisted);
  }

  async isBlacklisted(token: string): Promise<boolean> {
    const result = await this.blacklistRepo.findOne({ where: { token } });
    return !!result;
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async cleanupExpired() {
    await this.blacklistRepo.delete({ expiresAt: LessThan(new Date()) });
  }
}
