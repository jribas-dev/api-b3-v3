import { Module } from '@nestjs/common';
import { TenantService } from './tenant.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from 'src/instance/entities/instance.entity';

@Module({
  imports: [
    // só preciso do repositório de Instance (no DB principal)
    TypeOrmModule.forFeature([InstanceEntity]),
  ],
  providers: [TenantService],
  exports: [TenantService],
})
export class TenantModule {}
