// src/auth/blacklist.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TokenBlacklist } from './black-list.entity';
import { BlacklistService } from './black-list.service';

@Module({
  imports: [TypeOrmModule.forFeature([TokenBlacklist])],
  providers: [BlacklistService],
  exports: [BlacklistService],
})
export class BlacklistModule {}
