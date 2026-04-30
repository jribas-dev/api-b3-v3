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
import { EstoqueService } from './estoque.service';

type JwtRequest = { user: { userId: string; dbId: string } };

@Controller('b3dash/estoque')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
@RolesFront(RoleFrontEnum.ADMIN)
export class EstoqueController {
  constructor(private readonly estoqueService: EstoqueService) {}

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
      case 'entradas-vs-saidas':
        return this.estoqueService.graphEntradasVsSaidas(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'top-produtos-comprados':
        return this.estoqueService.graphTopProdutosComprados(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'top-fornecedores':
        return this.estoqueService.graphTopFornecedores(
          dbId,
          userId,
          query.idemp,
          query.periodo,
        );
      case 'curva-abc':
        // snapshot — período ignorado
        return this.estoqueService.graphCurvaAbc(dbId, userId, query.idemp);
      case 'ruptura':
        // snapshot — período ignorado
        return this.estoqueService.graphRuptura(dbId, userId, query.idemp);
      case 'valor-por-grupo':
        // snapshot — período ignorado
        return this.estoqueService.graphValorPorGrupo(
          dbId,
          userId,
          query.idemp,
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
    @Query() query: ListQueryDto & { apenasRuptura?: string },
  ) {
    const { dbId, userId } = req.user;
    switch (tipo) {
      case 'lancamentos':
        return this.estoqueService.listLancamentos(
          dbId,
          userId,
          query.idemp,
          query.periodo,
          query.page,
          query.limit,
          query.status, // tipo E/S/B mapeado via status no ListQueryDto
        );
      case 'por-produto':
        return this.estoqueService.listPorProduto(
          dbId,
          userId,
          query.idemp,
          query.page,
          query.limit,
          query.apenasRuptura === 'true',
        );
      case 'por-fornecedor':
        return this.estoqueService.listPorFornecedor(
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
