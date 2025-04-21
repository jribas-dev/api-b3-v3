import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from './entities/instance.entity';
import { InstanceService } from './instance.service';
import { InstanceController } from './instance.controller';

@Module({
  imports: [TypeOrmModule.forFeature([InstanceEntity])],
  providers: [InstanceService],
  controllers: [InstanceController],
  exports: [InstanceService],
})
export class InstanceModule {}
