import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { FormasPagamentoService } from 'src/b3vendas/formas-pagamento/formas-pagamento.service';
import { VendaService } from './venda.service';
import { CreateVendaDto } from './dto/create-venda.dto';
import { FecharVendaDto } from './dto/fechar-venda.dto';
import { ListVendasQueryDto } from './dto/list-vendas-query.dto';

@Controller('b3vendas/pedidos')
@UseGuards(JwtGuard, UserInstanceGuard)
export class VendaController {
  constructor(
    private readonly vendaService: VendaService,
    private readonly formasPagamentoService: FormasPagamentoService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Request() req: { user: { userId: string; dbId: string } },
    @Body() dto: CreateVendaDto,
  ) {
    return this.vendaService.create(req.user.dbId, req.user.userId, dto);
  }

  @Get('editaveis')
  async editaveis(
    @Request() req: { user: { userId: string; dbId: string } },
    @Query() query: ListVendasQueryDto,
  ) {
    return this.vendaService.findEditaveis(
      req.user.dbId,
      req.user.userId,
      query.idemp,
    );
  }

  @Get('fechados')
  async fechados(
    @Request() req: { user: { userId: string; dbId: string } },
    @Query() query: ListVendasQueryDto,
  ) {
    return this.vendaService.findFechados(
      req.user.dbId,
      req.user.userId,
      query.idemp,
    );
  }

  @Get(':id')
  async findOne(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.vendaService.findOne(req.user.dbId, req.user.userId, id);
  }

  @Get(':id/formas-disponiveis')
  async formas(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
  ) {
    const venda = await this.vendaService.findOne(
      req.user.dbId,
      req.user.userId,
      id,
    );
    if (venda.idcli == null) return [];
    return this.formasPagamentoService.formasDisponiveisParaCliente(
      req.user.dbId,
      venda.idcli,
    );
  }

  @Get(':id/condicoes-disponiveis')
  async condicoes(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
  ) {
    const venda = await this.vendaService.findOne(
      req.user.dbId,
      req.user.userId,
      id,
    );
    if (venda.idcli == null) return [];
    return this.formasPagamentoService.condicoesDisponiveisParaCliente(
      req.user.dbId,
      venda.idcli,
    );
  }

  @Post(':id/fechar')
  @HttpCode(HttpStatus.OK)
  async fechar(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: FecharVendaDto,
  ) {
    return this.vendaService.fechar(req.user.dbId, req.user.userId, id, dto);
  }
}
