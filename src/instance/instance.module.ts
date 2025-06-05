import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from './entities/instance.entity';
import { InstanceService } from './instance.service';
import { InstanceController } from './instance.controller';
import { UserInstanceModule } from 'src/user-instance/user-instance.module';
import { UserInstanceEntity } from 'src/user-instance/entities/user-instance.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([InstanceEntity, UserInstanceEntity]),
    UserInstanceModule,
  ],
  providers: [InstanceService],
  controllers: [InstanceController],
  exports: [InstanceService],
})
export class InstanceModule {}
