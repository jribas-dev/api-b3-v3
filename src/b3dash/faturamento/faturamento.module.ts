import { Module } from '@nestjs/common';
import { B3dashSharedModule } from '../shared/shared.module';
import { FaturamentoController } from './faturamento.controller';
import { FaturamentoService } from './faturamento.service';

@Module({
  imports: [B3dashSharedModule],
  controllers: [FaturamentoController],
  providers: [FaturamentoService],
})
export class FaturamentoModule {}
