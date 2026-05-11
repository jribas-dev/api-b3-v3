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
  BadRequestException,
  Delete,
  Query,
} from '@nestjs/common';
import { UserInstanceService } from './user-instance.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { AdminGuard } from 'src/auth/guards/admin.guard';
import { CreateUserInstanceDto } from './dto/create-user-instance.dto';
import { UpdateUserInstanceDto } from './dto/update-user-instance.dto';
import { RoleBack } from './enums/user-instance-roles.enum';

@UseGuards(JwtGuard)
@Controller('user-instances')
export class UserInstanceController {
  constructor(private readonly userInstanceService: UserInstanceService) {}

  @UseGuards(AdminGuard)
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
    if (user.userId !== userId && !user.isRoot) {
      throw new ForbiddenException(
        'Você não tem permissão para acessar este recurso',
      );
    }
    return this.userInstanceService.findByUser(userId);
  }

  @UseGuards(AdminGuard)
  @Get('db/:dbId')
  async findByDb(
    @Param('dbId') dbId: string,
    @Query('include') include?: string,
  ) {
    if (include !== undefined && include !== 'user' && include !== 'database') {
      throw new BadRequestException(
        "Parâmetro 'include' deve ser 'user' ou 'database'",
      );
    }
    return this.userInstanceService.findByDb(dbId, include);
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

  @UseGuards(AdminGuard)
  @Patch(':id')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updates: UpdateUserInstanceDto,
    @Request() req: { user: { isRoot: boolean; roleBack?: RoleBack } },
  ) {
    const existing = await this.userInstanceService.findOne(id);
    if (
      !req.user.isRoot &&
      req.user.roleBack === RoleBack.SUPER &&
      existing.roleback === RoleBack.ADMIN
    ) {
      throw new ForbiddenException(
        'Supervisores não podem alterar dados de administradores',
      );
    }
    return this.userInstanceService.update(id, updates);
  }

  @UseGuards(AdminGuard)
  @Delete(':id')
  async delete(
    @Param('id', ParseIntPipe) id: number,
    @Request() req: { user: { isRoot: boolean; roleBack?: RoleBack } },
  ) {
    const existing = await this.userInstanceService.findOne(id);
    if (
      !req.user.isRoot &&
      req.user.roleBack === RoleBack.SUPER &&
      existing.roleback === RoleBack.ADMIN
    ) {
      throw new ForbiddenException(
        'Supervisores não podem remover dados de administradores',
      );
    }
    await this.userInstanceService.delete(id);
    return { message: 'Usuário X Instância deletada com sucesso' };
  }
}
