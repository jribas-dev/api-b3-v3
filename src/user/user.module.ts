import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from './entities/user.entity';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { PasswordService } from 'src/auth/password/password.service';
import { AwsSenderModule } from 'src/infra/aws-ses/sender/sender.module';
import { UserInstanceModule } from 'src/user-instance/user-instance.module';
import { UserInstanceEntity } from 'src/user-instance/entities/user-instance.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity, UserInstanceEntity]),
    AwsSenderModule,
    UserInstanceModule,
  ],
  providers: [UserService, PasswordService],
  controllers: [UserController],
  exports: [UserService],
})
export class UserModule {}
