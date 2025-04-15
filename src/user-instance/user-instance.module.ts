import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserInstance } from './entities/user-instance.entity';
import { UserInstanceService } from './user-instance.service';
import { UserInstanceController } from './user-instance.controller';

@Module({
  imports: [TypeOrmModule.forFeature([UserInstance])],
  providers: [UserInstanceService],
  controllers: [UserInstanceController],
  exports: [UserInstanceService],
})
export class UserInstanceModule {}
