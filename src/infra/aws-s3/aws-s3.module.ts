import { Module } from '@nestjs/common';
import { AwsS3Service } from './aws-s3.service';
import { AwsS3Controller } from './aws-s3.controller';
import { s3ClientFactory } from './factories/s3-client.factory';

@Module({
  providers: [AwsS3Service, s3ClientFactory],
  controllers: [AwsS3Controller],
})
export class AwsS3Module {}
