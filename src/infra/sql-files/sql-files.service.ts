import { Injectable } from '@nestjs/common';
import { CreateSqlFileDto } from './dto/create-sql-file.dto';
import { UpdateSqlFileDto } from './dto/update-sql-file.dto';

@Injectable()
export class SqlFilesService {
  create(createSqlFileDto: CreateSqlFileDto) {
    return 'This action adds a new sqlFile';
  }

  findAll() {
    return `This action returns all sqlFiles`;
  }

  findOne(id: number) {
    return `This action returns a #${id} sqlFile`;
  }

  update(id: number, updateSqlFileDto: UpdateSqlFileDto) {
    return `This action updates a #${id} sqlFile`;
  }

  remove(id: number) {
    return `This action removes a #${id} sqlFile`;
  }
}
