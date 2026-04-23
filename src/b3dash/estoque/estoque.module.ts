import { Module } from '@nestjs/common';
import { B3dashSharedModule } from '../shared/shared.module';
import { EstoqueController } from './estoque.controller';
import { EstoqueService } from './estoque.service';

@Module({
  imports: [B3dashSharedModule],
  controllers: [EstoqueController],
  providers: [EstoqueService],
})
export class EstoqueModule {}
