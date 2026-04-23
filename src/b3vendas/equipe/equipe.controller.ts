import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import { RolesFront } from 'src/auth/decorators/roles-front.decorator';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RolesFrontGuard } from 'src/auth/guards/roles-front.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { RoleFront } from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { EquipeService } from './equipe.service';

@Controller('b3vendas/equipe')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
export class EquipeController {
  constructor(private readonly equipeService: EquipeService) {}

  @Get()
  @RolesFront(RoleFront.SUPER, RoleFront.SALER)
  async listar(
    @Request()
    req: {
      user: { userId: string; dbId: string; roleFront: RoleFront };
    },
  ) {
    return this.equipeService.listar(
      req.user.dbId,
      req.user.userId,
      req.user.roleFront,
    );
  }
}
