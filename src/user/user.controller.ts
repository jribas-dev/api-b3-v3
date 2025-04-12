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
import { User } from './user.entity';

@UseGuards(JwtGuard)
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @UseGuards(RootGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() userData: Partial<User>): Promise<User> {
    return this.userService.create(userData);
  }

  @UseGuards(RootGuard)
  @Get()
  async findAll(): Promise<User[]> {
    return this.userService.findAll();
  }

  @UseGuards(RootGuard)
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    const user = await this.userService.findOneById(id);
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }
    return user;
  }

  @Get('get/me')
  async findMe(
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ): Promise<User> {
    const user = await this.userService.findOneById(req.user.userId);
    if (!user) {
      throw new NotFoundException('Usuário pra lá de bagdá');
    }
    return user;
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() updateData: Partial<any>,
    @Request() req: { user: { isRoot: boolean; userId: string } },
  ) {
    const user: { isRoot: boolean; userId: string } = req.user;
    if (!user.isRoot && user.userId !== id) {
      throw new ForbiddenException('Você só pode editar seus próprios dados');
    }

    const updated = await this.userService.update(id, updateData);
    if (!updated) {
      throw new NotFoundException('Usuário não encontrado para atualização');
    }
    return updated;
  }
}
