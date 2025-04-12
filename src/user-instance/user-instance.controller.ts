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
import { UserInstance } from './user-instance.entity';

@UseGuards(JwtGuard)
@Controller('user-instances')
export class UserInstanceController {
  constructor(private readonly userInstanceService: UserInstanceService) {}

  @UseGuards(RootGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() data: Partial<UserInstance>): Promise<UserInstance> {
    return this.userInstanceService.create(data);
  }

  @Get('user/:userId')
  async findByUser(
    @Param('userId') userId: string,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ): Promise<UserInstance[]> {
    const user = req.user;
    if (user.userId !== userId) {
      throw new ForbiddenException(
        'Você não tem permissão para acessar este recurso',
      );
    }
    return this.userInstanceService.findByUser(userId);
  }

  @UseGuards(RootGuard)
  @Get('db/:dbId')
  async findByDb(@Param('dbId') dbId: string): Promise<UserInstance[]> {
    return this.userInstanceService.findByDb(dbId);
  }

  @Get(':id')
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ): Promise<UserInstance> {
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
    @Body() updates: Partial<UserInstance>,
  ): Promise<UserInstance> {
    return this.userInstanceService.update(id, updates);
  }
}
