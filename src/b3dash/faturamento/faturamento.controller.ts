import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Query,
  Request,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { CacheTTL } from '@nestjs/cache-manager';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { RolesFrontGuard } from 'src/auth/guards/roles-front.guard';
import { RolesFront } from 'src/auth/decorators/roles-front.decorator';
import { RoleFrontEnum } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { TenantAwareCacheInterceptor } from '../shared/tenant-aware-cache.interceptor';
import { GraphQueryDto } from '../shared/dto/graph-query.dto';
import { ListQueryDto } from '../shared/dto/list-query.dto';
import { FaturamentoService } from './faturamento.service';

type JwtRequest = { user: { userId: string; dbId: string } };

@Controller('b3dash/faturamento')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
@RolesFront(RoleFrontEnum.ADMIN)
export class FaturamentoController {
  constructor(private readonly faturamentoService: FaturamentoService) {}

  // ── Graphs ──────────────────────────────────────────────────────────────

  @Get('graph/:metrica')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(TenantAwareCacheInterceptor)
  @CacheTTL(86_400_000)
  async graph(
    @Request() req: JwtRequest,
    @Param('metrica') metrica: string,
    @Query() query: GraphQueryDto,
  ) {
    const { dbId, userId } = req.user;
    switch (metrica) {
      case 'evolucao':
        return this.faturamentoService.graphEvolucao(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'ticket-medio':
        return this.faturamentoService.graphTicketMedio(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'top-produtos':
        return this.faturamentoService.graphTopProdutos(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'top-clientes':
        return this.faturamentoService.graphTopClientes(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'ranking-vendedores':
        return this.faturamentoService.graphRankingVendedores(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'mix-operacoes':
        return this.faturamentoService.graphMixOperacoes(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      default:
        return null;
    }
  }

  // ── Lists ────────────────────────────────────────────────────────────────

  @Get('list/:tipo')
  @HttpCode(HttpStatus.OK)
  async list(
    @Request() req: JwtRequest,
    @Param('tipo') tipo: string,
    @Query() query: ListQueryDto,
  ) {
    const { dbId, userId } = req.user;
    switch (tipo) {
      case 'por-cliente':
        return this.faturamentoService.listPorCliente(
          dbId,
          userId,
          query.idemp,
          query.periodo,
          query.page,
          query.limit,
        );
      case 'por-produto':
        return this.faturamentoService.listPorProduto(
          dbId,
          userId,
          query.idemp,
          query.periodo,
          query.page,
          query.limit,
        );
      case 'por-vendedor':
        return this.faturamentoService.listPorVendedor(
          dbId,
          userId,
          query.idemp,
          query.periodo,
          query.page,
          query.limit,
        );
      default:
        return null;
    }
  }
}
