import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserInstanceEntity } from './entities/user-instance.entity';
import { UserInstanceService } from './user-instance.service';
import { UserInstanceController } from './user-instance.controller';
import { InstanceEntity } from 'src/instance/entities/instance.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserInstanceEntity, InstanceEntity])],
  providers: [UserInstanceService],
  controllers: [UserInstanceController],
  exports: [UserInstanceService],
})
export class UserInstanceModule {}
