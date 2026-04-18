import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { OperacaoController } from './operacao.controller';
import { OperacaoService } from './operacao.service';

@Module({
  imports: [B3vendasSharedModule],
  controllers: [OperacaoController],
  providers: [OperacaoService],
  exports: [OperacaoService],
})
export class OperacaoModule {}
