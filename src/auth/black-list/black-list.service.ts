// src/auth/services/blacklist.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
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

  async cleanupExpired() {
    await this.blacklistRepo.delete({ expiresAt: LessThan(new Date()) });
  }
}
