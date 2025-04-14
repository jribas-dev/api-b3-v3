import { Module } from '@nestjs/common';
import { AwsS3Module } from './aws-s3/aws-s3.module';
import { InfraService } from './infra.service';
import { InfraController } from './infra.controller';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [ConfigModule, AwsS3Module],
  providers: [InfraService],
  controllers: [InfraController],
})
export class InfraModule {}
