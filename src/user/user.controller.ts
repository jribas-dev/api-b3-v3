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
  UseGuards,
  Request,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RootGuard } from 'src/auth/guards/root.guard';
import { UserService } from './user.service';
import { User } from './entities/user.entity';
import { plainToInstance } from 'class-transformer';
import { UserResponseDto } from './dto/user-response.dto';
import { CreateUserDto } from './dto/user-create.dto';
import { UpdateUserDto } from './dto/user-update.dto';

@UseGuards(JwtGuard)
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @UseGuards(RootGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() userData: CreateUserDto): Promise<UserResponseDto> {
    const existingUser = await this.userService.findOneByEmail(
      (userData as Partial<User>).email,
    );
    if (existingUser) {
      throw new ForbiddenException('Email já cadastrado');
    }
    if ((userData as Partial<User>).phone) {
      const existingPhone = await this.userService.findOneByPhone(
        (userData as Partial<User>).phone,
      );
      if (existingPhone) {
        throw new ForbiddenException('Telefone já cadastrado');
      }
    }
    const newuser = await this.userService.create(userData as Partial<User>);
    if (!newuser) {
      throw new ForbiddenException('Erro ao criar usuário');
    }
    const userResponse = plainToInstance(UserResponseDto, newuser);
    return userResponse;
  }

  @UseGuards(RootGuard)
  @Get()
  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.userService.findAll();
    if (!users || users.length === 0) {
      throw new NotFoundException('Nenhum usuário encontrado');
    }
    return plainToInstance(UserResponseDto, users);
  }

  @UseGuards(RootGuard)
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<UserResponseDto> {
    const user = await this.userService.findOneById(id);
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }
    return plainToInstance(UserResponseDto, user);
  }

  @Get('get/me')
  async findMe(
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ): Promise<UserResponseDto> {
    const user = await this.userService.findOneById(req.user.userId);
    if (!user) {
      throw new NotFoundException('Usuário pra lá de bagdá');
    }
    return plainToInstance(UserResponseDto, user);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() @Body() updateData: UpdateUserDto,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ): Promise<UserResponseDto> {
    const user: { isRoot: boolean; userId: string } = req.user;
    if (!user.isRoot && user.userId !== id) {
      throw new ForbiddenException('Você só pode editar seus próprios dados');
    }

    const updated = await this.userService.update(
      id,
      updateData as Partial<User>,
    );
    if (!updated) {
      throw new NotFoundException('Usuário não encontrado para atualização');
    }
    return plainToInstance(UserResponseDto, updated);
  }
}
