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
import { JwtGuard } from 'src/auth/guards/jwt.guard';

@UseGuards(JwtGuard)
@Controller('sys-files')
export class SysFilesController {
  constructor(private readonly sysFilesService: SysFilesService) {}

  @UseGuards(RootGuard)
  @Post()
  create(@Body() createSysFileDto: CreateSysFileDto) {
    return this.sysFilesService.create(createSysFileDto);
  }

  @UseGuards(RootGuard)
  @Get()
  findAll() {
    return this.sysFilesService.findAll();
  }

  @UseGuards(JwtGuard)
  @Get(':idfile')
  findOne(@Param('idfile') idfile: string) {
    return this.sysFilesService.findOneById(+idfile);
  }

  @UseGuards(JwtGuard)
  @Get('system/:id/minor/:version')
  findMinorReleases(
    @Param('id') systemId: string,
    @Param('version') version: string,
  ) {
    return this.sysFilesService.getMinorReleases(systemId, version);
  }

  @UseGuards(JwtGuard)
  @Get('system/:id/major/:version/:versionDb')
  findMajorReleases(
    @Param('id') systemId: string,
    @Param('version') version: string,
    @Param('versionDb') versionDb: string,
  ) {
    return this.sysFilesService.getMajorReleases(systemId, version, versionDb);
  }

  @UseGuards(RootGuard)
  @Get('system/:id/bydays/:days')
  findOneByDays(@Param('days') idSystem: string, @Param('days') days: string) {
    return this.sysFilesService.findByDays(+idSystem, +days);
  }

  @UseGuards(RootGuard)
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateSysFileDto: UpdateSysFileDto) {
    return this.sysFilesService.update(+id, updateSysFileDto);
  }

  @UseGuards(RootGuard)
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.sysFilesService.remove(+id);
  }
}
