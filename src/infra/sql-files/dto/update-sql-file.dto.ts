import { PartialType } from '@nestjs/mapped-types';
import { CreateSqlFileDto } from './create-sql-file.dto';

export class UpdateSqlFileDto extends PartialType(CreateSqlFileDto) {}
