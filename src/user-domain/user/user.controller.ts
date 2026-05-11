import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  HttpCode,
  ForbiddenException,
  HttpStatus,
  Request,
  UseGuards,
  Delete,
} from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { SetActiveUserDto } from './dto/set-active-user.dto';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';
import { AdminGuard } from 'src/auth/guards/admin.guard';
import { UserInstanceService } from 'src/user-domain/user-instance/user-instance.service';
import { RoleBack } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';

@UseGuards(JwtGuard)
@Controller('users')
export class UserController {
  constructor(
    private readonly userService: UserService,
    private readonly userInstanceService: UserInstanceService,
  ) {}

  @Post()
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() userData: CreateUserDto) {
    const existingUser = await this.userService.findOneByEmail(userData.email);
    if (existingUser) {
      throw new ForbiddenException('Email já cadastrado');
    }
    if (userData.phone) {
      const existingPhone = await this.userService.findOneByPhone(
        userData.phone,
      );
      if (existingPhone) {
        throw new ForbiddenException('Telefone já cadastrado');
      }
    }
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$/;
    if (!passwordRegex.test(userData.password)) {
      throw new ForbiddenException(
        'A senha deve ter pelo menos 8 caracteres, incluindo letras e números',
      );
    }
    return await this.userService.create(userData);
  }

  @UseGuards(RootGuard)
  @Get()
  async findAll() {
    return await this.userService.findAll();
  }

  @Get('notin')
  @UseGuards(AdminGuard)
  async findInvitedNotInInstance(
    @Request() req: { user: { userId: string; dbId?: string } },
  ) {
    if (!req.user.dbId) {
      throw new ForbiddenException('Instância não selecionada');
    }
    return await this.userService.findInvitedNotInInstance(
      req.user.userId,
      req.user.dbId,
    );
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.userService.findOneById(id);
  }

  @Get('get/me')
  async findMe(@Request() req: { user: { isRoot: boolean; userId: string } }) {
    return await this.userService.findOneById(req.user.userId);
  }

  @Patch('active')
  @UseGuards(AdminGuard)
  async setActive(
    @Body() dto: SetActiveUserDto,
    @Request()
    req: { user: { isRoot: boolean; roleBack?: RoleBack; dbId?: string } },
  ) {
    if (
      !req.user.isRoot &&
      req.user.roleBack === RoleBack.SUPER &&
      req.user.dbId
    ) {
      const target = await this.userInstanceService.findOneByUserAndDb(
        dto.userId,
        req.user.dbId,
      );
      if (target?.roleback === RoleBack.ADMIN) {
        throw new ForbiddenException(
          'Supervisores não podem alterar dados de administradores',
        );
      }
    }
    return await this.userService.setActive(dto.userId, dto.isActive);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateData: UpdateUserDto,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ) {
    const user: { isRoot: boolean; userId: string } = req.user;
    if (!user.isRoot && user.userId !== id) {
      throw new ForbiddenException('Você só pode editar seus próprios dados');
    }
    return await this.userService.update(id, updateData);
  }

  @UseGuards(RootGuard)
  @Delete(':id')
  async delete(@Param('id') id: string) {
    await this.userService.delete(id);
    return { message: 'Usuário deletado com sucesso' };
  }
}
