import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import { RolesFront } from 'src/auth/decorators/roles-front.decorator';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RolesFrontGuard } from 'src/auth/guards/roles-front.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import {
  RoleFront,
  RoleFrontEnum,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { MetricasService } from './metricas.service';

type AuthenticatedRequest = {
  user: { userId: string; dbId: string; roleFront: RoleFront };
};

@Controller('b3vendas/metricas')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
@RolesFront(RoleFrontEnum.SUPERSALER, RoleFrontEnum.SALER)
export class MetricasController {
  constructor(private readonly metricasService: MetricasService) {}

  @Get('vendas-semanais')
  async vendasSemanais(@Request() req: AuthenticatedRequest) {
    return this.metricasService.vendasSemanais(
      req.user.dbId,
      req.user.userId,
      req.user.roleFront,
    );
  }

  @Get('vendas-mensais')
  async vendasMensais(@Request() req: AuthenticatedRequest) {
    return this.metricasService.vendasMensais(
      req.user.dbId,
      req.user.userId,
      req.user.roleFront,
    );
  }

  @Get('top-clientes-ativos')
  async topClientesAtivos(@Request() req: AuthenticatedRequest) {
    return this.metricasService.topClientesAtivos(
      req.user.dbId,
      req.user.userId,
      req.user.roleFront,
    );
  }

  @Get('clientes-inativos')
  async clientesInativos(@Request() req: AuthenticatedRequest) {
    return this.metricasService.clientesInativos(
      req.user.dbId,
      req.user.userId,
      req.user.roleFront,
    );
  }
}
