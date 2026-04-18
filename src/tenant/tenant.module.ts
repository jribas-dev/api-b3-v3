import { Module } from '@nestjs/common';
import { TenantService } from './tenant.service';
import { CfgService } from './cfg.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from 'src/user-domain/instance/entities/instance.entity';

@Module({
  imports: [
    // só preciso do repositório de Instance (no DB principal)
    TypeOrmModule.forFeature([InstanceEntity]),
  ],
  providers: [TenantService, CfgService],
  exports: [TenantService, CfgService],
})
export class TenantModule {}
