import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { ProdutoService } from './produto.service';
import { CalcImpostoDto } from './dto/calc-imposto.dto';

@Controller('b3vendas/produtos')
@UseGuards(JwtGuard, UserInstanceGuard)
export class ProdutoController {
  constructor(private readonly produtoService: ProdutoService) {}

  @Get('buscar')
  async buscar(
    @Request() req: { user: { dbId: string } },
    @Query('q') q: string,
  ) {
    return this.produtoService.buscar(req.user.dbId, q ?? '');
  }

  @Get(':id/preco')
  async preco(
    @Request() req: { user: { dbId: string } },
    @Param('id', ParseIntPipe) id: number,
    @Query('idCli', ParseIntPipe) idCli: number,
    @Query('idOper', ParseIntPipe) idOper: number,
  ) {
    return this.produtoService.preco(req.user.dbId, id, idCli, idOper);
  }

  @Post(':id/calc-imposto')
  async calcImposto(
    @Request() req: { user: { dbId: string } },
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CalcImpostoDto,
  ) {
    return this.produtoService.calcImposto(
      req.user.dbId,
      id,
      dto.subtotal,
      dto.idOper,
    );
  }
}
