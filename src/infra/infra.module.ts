import { Module } from '@nestjs/common';
import { AwsS3Module } from './aws-s3/aws-s3.module';
import { InfraService } from './infra.service';
import { InfraController } from './infra.controller';
import { ConfigModule } from '@nestjs/config';
import { SysFilesModule } from './sys-files/sys-files.module';
import { SqlFilesModule } from './sql-files/sql-files.module';
import { AwsSesModule } from './aws-ses/aws-ses.module';

@Module({
  imports: [ConfigModule, AwsS3Module, SysFilesModule, SqlFilesModule, AwsSesModule],
  providers: [InfraService],
  controllers: [InfraController],
})
export class InfraModule {}
