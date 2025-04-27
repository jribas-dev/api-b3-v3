import { Module } from '@nestjs/common';
import { UserPreService } from './user-pre.service';
import { UserPreController } from './user-pre.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserPreEntity } from './entities/user-pre.entity';
import { UserPreInstanceEntity } from './entities/user-pre-instances.entity';
import { AwsSenderModule } from 'src/infra/aws-ses/sender/sender.module';
import { UserModule } from 'src/user/user.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserPreEntity, UserPreInstanceEntity]),
    UserModule,
    AwsSenderModule,
  ],
  providers: [UserPreService],
  controllers: [UserPreController],
})
export class UserPreModule {}
