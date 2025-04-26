import { Module } from '@nestjs/common';
import { AwsSesService } from './aws-ses.service';
import { AwsSesController } from './aws-ses.controller';
import { SesClientFactory } from './factories/ses-client.factory';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountSESEntity } from './entities/account-ses.entity';
import { AwsSenderModule } from './sender/sender.module';

@Module({
  imports: [TypeOrmModule.forFeature([AccountSESEntity]), AwsSenderModule],
  providers: [AwsSesService, SesClientFactory],
  controllers: [AwsSesController],
})
export class AwsSesModule {}
