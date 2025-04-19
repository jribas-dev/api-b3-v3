import { Module } from '@nestjs/common';
import { SqlFilesService } from './sql-files.service';
import { SqlFilesController } from './sql-files.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemsEntity } from '../common/system.entity';
import { SqlFilesEntity } from './entities/sql-file.entity';

@Module({
  imports: [TypeOrmModule.forFeature([SystemsEntity, SqlFilesEntity])],
  controllers: [SqlFilesController],
  providers: [SqlFilesService],
})
export class SqlFilesModule {}
