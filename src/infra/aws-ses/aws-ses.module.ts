import { Module } from '@nestjs/common';
import { AwsSesService } from './aws-ses.service';
import { AwsSesController } from './aws-ses.controller';
import { SesClientFactory } from './factories/ses-client.factory';

@Module({
  providers: [AwsSesService, SesClientFactory],
  controllers: [AwsSesController],
})
export class AwsSesModule {}
