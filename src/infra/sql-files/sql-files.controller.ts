import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseFilePipe,
  MaxFileSizeValidator,
  FileTypeValidator,
} from '@nestjs/common';
import { SqlFilesService } from './sql-files.service';
import { CreateSqlFileDto } from './dto/create-sql-file.dto';
import { UpdateSqlFileDto } from './dto/update-sql-file.dto';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';
import { DownloadSqlFileDto } from './dto/download-sql-file';
import { FileInterceptor } from '@nestjs/platform-express';

@UseGuards(JwtGuard)
@Controller('sql-files')
export class SqlFilesController {
  constructor(private readonly sqlFilesService: SqlFilesService) {}

  @UseGuards(RootGuard)
  @Post()
  @UseInterceptors(FileInterceptor('sqlFile'))
  async create(
    @Body() createSqlFileDto: CreateSqlFileDto,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({
            maxSize: 1024 * 1024 * 10, // 10MB
          }),
          new FileTypeValidator({
            fileType: '.(sql|txt)',
          }),
        ],
      }),
    )
    file: Express.Multer.File,
  ) {
    createSqlFileDto.script = file.buffer;
    return await this.sqlFilesService.create(createSqlFileDto);
  }

  @UseGuards(RootGuard)
  @Get()
  async findAll() {
    return await this.sqlFilesService.findAll();
  }

  @UseGuards(RootGuard)
  @Get('system/:id/bydays/:days')
  async findByDays(@Param('id') idSystem: string, @Param('days') days: string) {
    return await this.sqlFilesService.findByDays(+idSystem, +days);
  }

  @UseGuards(JwtGuard)
  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.sqlFilesService.findOneById(+id);
  }

  @UseGuards(JwtGuard)
  @Get('system/:id/updates/:version')
  async findReleasesFrom(
    @Param('id') systemId: string,
    @Param('version') version: string,
  ) {
    return await this.sqlFilesService.getReleasesFrom(+systemId, +version);
  }

  @UseGuards(JwtGuard)
  @Get('system/:id')
  async findFullRelease(@Param('id') systemId: string) {
    return await this.sqlFilesService.getLastFullRelease(+systemId);
  }

  @UseGuards(JwtGuard)
  @Get('download/:id')
  async downloadSql(@Param('id') id: string): Promise<DownloadSqlFileDto> {
    const buffer: Buffer = await this.sqlFilesService.getSQLBinary(+id);
    const newDownload = new DownloadSqlFileDto();

    newDownload.idSql = +id;
    newDownload.sqlData = buffer.toString('base64');

    return newDownload;
  }

  @UseGuards(RootGuard)
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateSqlFileDto: UpdateSqlFileDto,
  ) {
    return await this.sqlFilesService.update(+id, updateSqlFileDto);
  }

  @UseGuards(RootGuard)
  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.sqlFilesService.remove(+id);
  }
}
