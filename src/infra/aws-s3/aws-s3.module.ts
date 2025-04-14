import { Module } from '@nestjs/common';
import { AwsS3Service } from './aws-s3.service';
import { AwsS3Controller } from './aws-s3.controller';
import { MulterModule } from '@nestjs/platform-express';
import { MulterOptionsFactory } from './factories/multer-options.factory';
import { s3ClientFactory } from './factories/s3-client.factory';

@Module({
  imports: [
    MulterModule.registerAsync({
      useClass: MulterOptionsFactory,
    }),
  ],
  providers: [AwsS3Service, MulterOptionsFactory, s3ClientFactory],
  controllers: [AwsS3Controller],
})
export class AwsS3Module {}
