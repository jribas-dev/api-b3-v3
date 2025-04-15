import { Module } from '@nestjs/common';
import { SqlFilesService } from './sql-files.service';
import { SqlFilesController } from './sql-files.controller';

@Module({
  controllers: [SqlFilesController],
  providers: [SqlFilesService],
})
export class SqlFilesModule {}
