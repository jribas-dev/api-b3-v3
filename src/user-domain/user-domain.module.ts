import { Module } from '@nestjs/common';
import { UserModule } from './user/user.module';
import { UserPreModule } from './user-pre/user-pre.module';
import { UserInstanceModule } from './user-instance/user-instance.module';
import { InstanceModule } from './instance/instance.module';

@Module({
  imports: [UserModule, UserPreModule, UserInstanceModule, InstanceModule],
  exports: [UserModule, UserPreModule, UserInstanceModule, InstanceModule],
})
export class UserDomainModule {}
