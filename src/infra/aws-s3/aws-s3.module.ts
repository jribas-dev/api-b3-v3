import { Module } from '@nestjs/common';
import { AwsS3Service } from './aws-s3.service';
import { AwsS3Controller } from './aws-s3.controller';
import { MulterModule } from '@nestjs/platform-express';
import { MulterOptionsFactory } from './multer-options.factory';

@Module({
  imports: [
    MulterModule.registerAsync({
      useClass: MulterOptionsFactory,
    }),
  ],
  providers: [AwsS3Service, MulterOptionsFactory],
  controllers: [AwsS3Controller],
})
export class AwsS3Module {}
