import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { VendaItemService } from './venda-item.service';
import { CreateVendaItemDto } from './dto/create-venda-item.dto';

@Controller('b3vendas/pedidos/:id/itens')
@UseGuards(JwtGuard, UserInstanceGuard)
export class VendaItemController {
  constructor(private readonly vendaItemService: VendaItemService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async add(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreateVendaItemDto,
  ) {
    return this.vendaItemService.add(req.user.dbId, req.user.userId, id, dto);
  }

  @Delete(':seq')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
    @Param('seq', ParseIntPipe) seq: number,
  ) {
    await this.vendaItemService.remove(req.user.dbId, req.user.userId, id, seq);
  }
}
