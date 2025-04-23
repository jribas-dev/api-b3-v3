import { Module } from '@nestjs/common';
import { AwsSesService } from './aws-ses.service';
import { AwsSesController } from './aws-ses.controller';

@Module({
  providers: [AwsSesService],
  controllers: [AwsSesController]
})
export class AwsSesModule {}
