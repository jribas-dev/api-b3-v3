import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { RolesFront } from 'src/auth/decorators/roles-front.decorator';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RolesFrontGuard } from 'src/auth/guards/roles-front.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { RoleFrontEnum } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { ClienteService } from './cliente.service';
import { CreateClienteDto } from './dto/create-cliente.dto';
import { UpdateClienteDto } from './dto/update-cliente.dto';

@Controller('b3vendas/clientes')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
export class ClienteController {
  constructor(private readonly clienteService: ClienteService) {}

  @Get('buscar')
  async buscar(
    @Request() req: { user: { userId: string; dbId: string } },
    @Query('q') q: string,
  ) {
    return this.clienteService.buscar(req.user.dbId, req.user.userId, q ?? '');
  }

  @Get('rede-sp')
  @RolesFront(RoleFrontEnum.SUPERSALER, RoleFrontEnum.SALER)
  async redeSp(@Request() req: { user: { userId: string; dbId: string } }) {
    return this.clienteService.redeSp(req.user.dbId, req.user.userId);
  }

  @Get('tabela')
  @RolesFront(RoleFrontEnum.SUPERSALER, RoleFrontEnum.SALER)
  async tabela(
    @Request() req: { user: { dbId: string } },
    @Query('idOper', ParseIntPipe) idOper: number,
    @Query('idCli', ParseIntPipe) idCli: number,
  ) {
    return this.clienteService.tabela(req.user.dbId, idOper, idCli);
  }

  @Get(':id')
  async info(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.clienteService.info(req.user.dbId, id);
  }

  @Post()
  @RolesFront(RoleFrontEnum.SUPERSALER)
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Request() req: { user: { userId: string; dbId: string } },
    @Body() dto: CreateClienteDto,
  ) {
    return this.clienteService.create(req.user.dbId, req.user.userId, dto);
  }

  @Patch(':id')
  @RolesFront(RoleFrontEnum.SUPERSALER)
  async update(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateClienteDto,
  ) {
    return this.clienteService.update(req.user.dbId, req.user.userId, id, dto);
  }

  @Delete(':id')
  @RolesFront(RoleFrontEnum.SUPERSALER)
  async remove(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.clienteService.remove(req.user.dbId, id);
  }
}
