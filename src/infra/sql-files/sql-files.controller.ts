import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { SqlFilesService } from './sql-files.service';
import { CreateSqlFileDto } from './dto/create-sql-file.dto';
import { UpdateSqlFileDto } from './dto/update-sql-file.dto';

@Controller('sql-files')
export class SqlFilesController {
  constructor(private readonly sqlFilesService: SqlFilesService) {}

  @Post()
  create(@Body() createSqlFileDto: CreateSqlFileDto) {
    return this.sqlFilesService.create(createSqlFileDto);
  }

  @Get()
  findAll() {
    return this.sqlFilesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.sqlFilesService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateSqlFileDto: UpdateSqlFileDto) {
    return this.sqlFilesService.update(+id, updateSqlFileDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.sqlFilesService.remove(+id);
  }
}
