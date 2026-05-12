import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstanceEntity } from './entities/instance.entity';
import { InstanceService } from './instance.service';
import { InstanceController } from './instance.controller';
import { UserInstanceModule } from 'src/user-domain/user-instance/user-instance.module';
import { UserInstanceEntity } from 'src/user-domain/user-instance/entities/user-instance.entity';
import { UserEntity } from 'src/user-domain/user/entities/user.entity';
import { TenantModule } from 'src/tenant/tenant.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([InstanceEntity, UserInstanceEntity, UserEntity]),
    UserInstanceModule,
    TenantModule,
  ],
  providers: [InstanceService],
  controllers: [InstanceController],
  exports: [InstanceService],
})
export class InstanceModule {}
