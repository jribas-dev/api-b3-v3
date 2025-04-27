import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from './entities/user.entity';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { PasswordService } from 'src/auth/password/password.service';
import { AwsSenderModule } from 'src/infra/aws-ses/sender/sender.module';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity]), AwsSenderModule],
  providers: [UserService, PasswordService],
  controllers: [UserController],
  exports: [UserService],
})
export class UserModule {}
