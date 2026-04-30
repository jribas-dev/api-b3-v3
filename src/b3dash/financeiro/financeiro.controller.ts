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
import { FinanceiroService } from './financeiro.service';

type JwtRequest = { user: { userId: string; dbId: string } };

@Controller('b3dash/financeiro')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
@RolesFront(RoleFrontEnum.ADMIN)
export class FinanceiroController {
  constructor(private readonly financeiroService: FinanceiroService) {}

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
      case 'receber-vs-pagar':
        return this.financeiroService.graphReceberVsPagar(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'fluxo-caixa-projetado':
        return this.financeiroService.graphFluxoCaixaProjetado(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'inadimplencia':
        // snapshot — período ignorado
        return this.financeiroService.graphInadimplencia(
          dbId,
          userId,
          query.idemp,
        );
      case 'top-inadimplentes':
        return this.financeiroService.graphTopInadimplentes(
          dbId,
          userId,
          query.idemp,
        );
      case 'entradas-por-especie':
        return this.financeiroService.graphEntradasPorEspecie(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'saldo-destinos':
        return this.financeiroService.graphSaldoDestinos(
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
      case 'receber':
        return this.financeiroService.listReceber(
          dbId,
          userId,
          query.idemp,
          query.periodo,
          query.page,
          query.limit,
          query.status,
        );
      case 'pagar':
        return this.financeiroService.listPagar(
          dbId,
          userId,
          query.idemp,
          query.periodo,
          query.page,
          query.limit,
          query.status,
        );
      case 'movimentos':
        return this.financeiroService.listMovimentos(
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
