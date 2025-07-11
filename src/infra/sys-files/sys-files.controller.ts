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
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';

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
  async findAll() {
    return await this.sysFilesService.findAll();
  }

  @UseGuards(JwtGuard)
  @Get(':idfile')
  async findOne(@Param('idfile') idfile: string) {
    return await this.sysFilesService.findOneById(+idfile);
  }

  @UseGuards(JwtGuard)
  @Get('system/:id/releases/:version/:versionDb')
  async findMinorReleases(
    @Param('id') systemId: string,
    @Param('version') version: string,
    @Param('versionDb') versionDb: string,
  ) {
    return await this.sysFilesService.getReleases(systemId, version, versionDb);
  }

  @UseGuards(JwtGuard)
  @Get('system/:id/fullpack/:versionDb')
  async findFullRelease(
    @Param('id') systemId: string,
    @Param('versionDb') versionDb: string,
  ) {
    return await this.sysFilesService.getFullRelease(systemId, versionDb);
  }

  @UseGuards(RootGuard)
  @Get('system/:id/bydays/:days')
  async findByDays(@Param('id') idSystem: string, @Param('days') days: string) {
    return await this.sysFilesService.findByDays(+idSystem, +days);
  }

  @UseGuards(RootGuard)
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateSysFileDto: UpdateSysFileDto,
  ) {
    return await this.sysFilesService.update(+id, updateSysFileDto);
  }

  @UseGuards(RootGuard)
  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.sysFilesService.remove(+id);
  }
}
