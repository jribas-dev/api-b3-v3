import { Module } from '@nestjs/common';
import { TenantService } from './tenant.service';
import { CfgService } from './cfg.service';
import { EmpService } from './emp.service';
import { TenantController } from './tenant.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from 'src/user-domain/instance/entities/instance.entity';

@Module({
  imports: [
    // só preciso do repositório de Instance (no DB principal)
    TypeOrmModule.forFeature([InstanceEntity]),
  ],
  controllers: [TenantController],
  providers: [TenantService, CfgService, EmpService],
  exports: [TenantService, CfgService, EmpService],
})
export class TenantModule {}
