import { Controller, Get, Query, Request, UseGuards } from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { OperacaoService } from './operacao.service';
import { ListOperacoesQueryDto } from './dto/list-operacoes-query.dto';

@Controller('b3vendas/operacoes')
@UseGuards(JwtGuard, UserInstanceGuard)
export class OperacaoController {
  constructor(private readonly operacaoService: OperacaoService) {}

  @Get()
  async listar(
    @Request() req: { user: { userId: string; dbId: string } },
    @Query() query: ListOperacoesQueryDto,
  ) {
    return this.operacaoService.listarPermitidas(
      req.user.dbId,
      req.user.userId,
      query.idemp,
    );
  }
}
