import {
  IsBase64,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';
import { SqlFilesEntity } from '../entities/sql-file.entity';
import { OmitType } from '@nestjs/mapped-types';
import { SqlFilesTipo } from '../enums/sql-files-tipo.enum';

export class CreateSqlFileDto extends OmitType(SqlFilesEntity, [
  'idSql',
  'dthrSql',
]) {
  @IsOptional()
  @IsNumber()
  idSystem: number | null;

  @IsString()
  @IsNotEmpty()
  tipo: SqlFilesTipo;

  @IsNumber()
  @IsNotEmpty()
  versaoDb: number;

  @IsOptional()
  @IsString()
  obs: string | null;

  @IsString()
  @IsNotEmpty()
  @IsBase64()
  sqlData: string;
}
