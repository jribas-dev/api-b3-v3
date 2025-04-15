import { PartialType } from '@nestjs/mapped-types';
import { CreateSysFileDto } from './create-sys-file.dto';

export class UpdateSysFileDto extends PartialType(CreateSysFileDto) {}
