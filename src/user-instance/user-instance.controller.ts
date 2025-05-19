import {
  Controller,
  Post,
  Patch,
  Get,
  Param,
  Body,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
  UseGuards,
  Request,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { UserInstanceService } from './user-instance.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';
import { CreateUserInstanceDto } from './dto/create-user-instance.dto';
import { UpdateUserInstanceDto } from './dto/update-user-instance.dto';

@UseGuards(JwtGuard)
@Controller('user-instances')
export class UserInstanceController {
  constructor(private readonly userInstanceService: UserInstanceService) {}

  @UseGuards(RootGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() data: CreateUserInstanceDto) {
    return this.userInstanceService.create(data);
  }

  @Get('user/:userId')
  async findByUser(
    @Param('userId') userId: string,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ) {
    const user = req.user;
    if (user.userId !== userId || !user.isRoot) {
      throw new ForbiddenException(
        'Você não tem permissão para acessar este recurso',
      );
    }
    return this.userInstanceService.findByUser(userId);
  }

  @UseGuards(RootGuard)
  @Get('db/:dbId')
  async findByDb(@Param('dbId') dbId: string) {
    return this.userInstanceService.findByDb(dbId);
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ) {
    const userInstance = await this.userInstanceService.findOne(id);
    if (!userInstance) {
      throw new NotFoundException('Instancia não encontrada');
    }
    if (req.user.userId !== userInstance.userId) {
      throw new ForbiddenException(
        'Você não tem permissão para acessar este recurso',
      );
    }
    return userInstance;
  }

  @UseGuards(RootGuard)
  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updates: UpdateUserInstanceDto,
  ) {
    return this.userInstanceService.update(id, updates);
  }
}
