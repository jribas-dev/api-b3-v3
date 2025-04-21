import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Body,
  HttpCode,
  NotFoundException,
  ForbiddenException,
  HttpStatus,
  Request,
  UseGuards,
} from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';

@UseGuards(JwtGuard)
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
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
    const users = await this.userService.findAll();
    if (!users || users.length === 0) {
      throw new NotFoundException('Nenhum usuário encontrado');
    }
    return users;
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.userService.findOneById(id);
  }

  @Get('get/me')
  async findMe(@Request() req: { user: { isRoot: boolean; userId: string } }) {
    const user = await this.userService.findOneById(req.user.userId);
    if (!user) {
      throw new NotFoundException('Usuário pra lá de bagdá');
    }
    return user;
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
}
