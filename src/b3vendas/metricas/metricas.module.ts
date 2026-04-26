import { Module } from '@nestjs/common';
import { B3vendasSharedModule } from 'src/b3vendas/shared/shared.module';
import { MetricasController } from './metricas.controller';
import { MetricasService } from './metricas.service';

@Module({
  imports: [B3vendasSharedModule],
  controllers: [MetricasController],
  providers: [MetricasService],
  exports: [MetricasService],
})
export class MetricasModule {}
