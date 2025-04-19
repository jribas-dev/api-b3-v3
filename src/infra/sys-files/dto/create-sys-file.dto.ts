import { OmitType } from '@nestjs/mapped-types';
import { SysFilesEntity } from '../entities/sys-file.entity';
import { SysFilesTipo } from '../enums/sys-files-tipo.enum';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  IsUrl,
} from 'class-validator';

export class CreateSysFileDto extends OmitType(SysFilesEntity, [
  'idFile',
  'dthrFile',
  'versaoDb',
] as const) {
  @IsOptional()
  @IsInt()
  idSystem: number | null;

  @IsEnum(SysFilesTipo)
  tipo: SysFilesTipo;

  @IsNotEmpty()
  @IsNumber()
  versao: number;

  @IsNotEmpty()
  @IsString()
  fileName: string;

  @IsOptional()
  @IsUrl()
  url: string | null;

  @IsOptional()
  @IsString()
  s3Key: string | null;
}
