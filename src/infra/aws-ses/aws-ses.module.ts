import { Module } from '@nestjs/common';
import { AwsSesService } from './aws-ses.service';
import { AwsSesController } from './aws-ses.controller';
import { SesClientFactory } from './factories/ses-client.factory';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountSESEntity } from './entities/account-ses.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AccountSESEntity])],
  providers: [AwsSesService, SesClientFactory],
  controllers: [AwsSesController],
})
export class AwsSesModule {}
