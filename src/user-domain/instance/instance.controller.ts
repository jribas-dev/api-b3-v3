import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  HttpStatus,
  HttpCode,
  UseGuards,
} from '@nestjs/common';
import { InstanceService } from './instance.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';
import { CreateInstanceDto } from './dto/create-instance.dto';
import { UpdateInstanceDto } from './dto/update-instance.dto';

@UseGuards(JwtGuard)
@Controller('instances')
export class InstanceController {
  constructor(private readonly InstanceService: InstanceService) {}

  @UseGuards(RootGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() data: Partial<CreateInstanceDto>) {
    return this.InstanceService.create(data);
  }

  @UseGuards(RootGuard)
  @Get()
  async findAll() {
    return await this.InstanceService.findAll();
  }

  @UseGuards(RootGuard)
  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.InstanceService.findOneById(id);
  }

  @UseGuards(RootGuard)
  @Patch(':id')
  async update(@Param('id') id: string, @Body() updates: UpdateInstanceDto) {
    return await this.InstanceService.update(id, updates);
  }
}
