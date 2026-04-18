import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { ProdutoController } from './produto.controller';
import { ProdutoService } from './produto.service';
import { TaxCalculatorService } from './tax-calculator.service';

@Module({
  imports: [B3vendasSharedModule],
  controllers: [ProdutoController],
  providers: [ProdutoService, TaxCalculatorService],
  exports: [ProdutoService, TaxCalculatorService],
})
export class ProdutoModule {}
