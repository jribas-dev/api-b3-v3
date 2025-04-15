import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Instance } from './entities/instance.entity';
import { InstanceService } from './instance.service';
import { InstanceController } from './instance.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Instance])],
  providers: [InstanceService],
  controllers: [InstanceController],
  exports: [InstanceService],
})
export class InstanceModule {}
