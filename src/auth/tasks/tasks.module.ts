import { Module } from '@nestjs/common';
import { BlacklistModule } from '../black-list/black-list.module';
import { RefreshTokenModule } from '../refresh-token/refresh-token.module';
import { TasksService } from './tasks.service';

@Module({
  imports: [BlacklistModule, RefreshTokenModule],
  providers: [TasksService],
})
export class TasksModule {}
