import { Module } from '@nestjs/common';
import { SysFilesService } from './sys-files.service';
import { SysFilesController } from './sys-files.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemsEntity } from '../common/system.entity';
import { SysFilesEntity } from './entities/sys-file.entity';
import { SqlFilesService } from '../sql-files/sql-files.service';
import { SqlFilesEntity } from '../sql-files/entities/sql-file.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([SystemsEntity, SysFilesEntity, SqlFilesEntity]),
  ],
  controllers: [SysFilesController],
  providers: [SysFilesService, SqlFilesService],
})
export class SysFilesModule {}
