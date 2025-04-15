import { Module } from '@nestjs/common';
import { SysFilesService } from './sys-files.service';
import { SysFilesController } from './sys-files.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemsEntity } from '../common/system.entity';
import { SysFilesEntity } from './entities/sys-file.entity';

@Module({
  imports: [TypeOrmModule.forFeature([SystemsEntity, SysFilesEntity])],
  controllers: [SysFilesController],
  providers: [SysFilesService],
})
export class SysFilesModule {}
