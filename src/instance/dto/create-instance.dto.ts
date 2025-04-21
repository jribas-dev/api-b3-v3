import { OmitType } from '@nestjs/mapped-types';
import { IsString, IsBoolean, IsInt } from 'class-validator';
import { InstanceEntity } from '../entities/instance.entity';

export class CreateInstanceDto extends OmitType(InstanceEntity, [
  'dbId',
  'createdAt',
  'updatedAt',
] as const) {
  @IsString()
  name: string;

  @IsString()
  dbName: string;

  @IsString()
  dbHost: string;

  @IsInt()
  maxcompanies: number;

  @IsInt()
  maxusers: number;

  @IsBoolean()
  isActive: boolean;
}
