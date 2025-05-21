import { IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { SqlFilesEntity } from '../entities/sql-file.entity';
import { OmitType } from '@nestjs/mapped-types';
import { SqlFilesTipo } from '../enums/sql-files-tipo.enum';
import { Transform } from 'class-transformer';

export class CreateSqlFileDto extends OmitType(SqlFilesEntity, [
  'idSql',
  'dthrSql',
]) {
  @IsString()
  @IsNotEmpty()
  @Transform(({ value }) => Number(value))
  idSystem: number | null;

  @IsString()
  @IsNotEmpty()
  tipo: SqlFilesTipo;

  @IsString()
  @IsNotEmpty()
  @Transform(({ value }) => Number(value))
  versaoDb: number;

  @IsOptional()
  @IsString()
  obs: string | null;
}
