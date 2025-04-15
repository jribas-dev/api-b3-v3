import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { SysFilesService } from './sys-files.service';
import { CreateSysFileDto } from './dto/create-sys-file.dto';
import { UpdateSysFileDto } from './dto/update-sys-file.dto';
import { RootGuard } from 'src/auth/guards/root.guard';

@UseGuards(RootGuard)
@Controller('sys-files')
export class SysFilesController {
  constructor(private readonly sysFilesService: SysFilesService) {}

  @Post()
  create(@Body() createSysFileDto: CreateSysFileDto) {
    return this.sysFilesService.create(createSysFileDto);
  }

  @Get()
  findAll() {
    return this.sysFilesService.findAll();
  }

  @Get(':idfile')
  findOne(@Param('idfile') idfile: string) {
    return this.sysFilesService.findOneById(+idfile);
  }

  @Get('system/:id/bydays/:days')
  findOneByDays(@Param('days') idSystem: string, @Param('days') days: string) {
    return this.sysFilesService.findByDays(+idSystem, +days);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateSysFileDto: UpdateSysFileDto) {
    return this.sysFilesService.update(+id, updateSysFileDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.sysFilesService.remove(+id);
  }
}
