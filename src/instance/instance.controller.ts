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
  NotFoundException,
} from '@nestjs/common';
import { InstanceService } from './instance.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';
import { Instance } from './entities/instance.entity';

@UseGuards(JwtGuard)
@Controller('instances')
export class InstanceController {
  constructor(private readonly instanceService: InstanceService) {}

  @UseGuards(RootGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() data: Partial<Instance>): Promise<Instance> {
    return this.instanceService.create(data);
  }

  @UseGuards(RootGuard)
  @Get()
  async findAll(): Promise<Instance[]> {
    return this.instanceService.findAll();
  }

  @UseGuards(RootGuard)
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Instance> {
    const instance = await this.instanceService.findOneById(id);
    if (!instance) {
      throw new NotFoundException('Instância não encontrada');
    }
    return instance;
  }

  @UseGuards(RootGuard)
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updates: Partial<Instance>,
  ): Promise<Instance> {
    const updated = await this.instanceService.update(id, updates);
    if (!updated) {
      throw new NotFoundException('Instância não encontrada para atualização');
    }
    return updated;
  }
}
