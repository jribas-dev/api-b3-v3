import { Module } from '@nestjs/common';
import { TenantService } from './tenant.service';
import { CfgService } from './cfg.service';
import { EmpService } from './emp.service';
import { UsuService } from './usu.service';
import { TenantController } from './tenant.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from 'src/user-domain/instance/entities/instance.entity';

@Module({
  imports: [
    // só preciso do repositório de Instance (no DB principal)
    TypeOrmModule.forFeature([InstanceEntity]),
  ],
  controllers: [TenantController],
  providers: [TenantService, CfgService, EmpService, UsuService],
  exports: [TenantService, CfgService, EmpService, UsuService],
})
export class TenantModule {}
