import { Module } from '@nestjs/common';
import { B3dashSharedModule } from '../shared/shared.module';
import { UsuController } from './usu.controller';
import { UsuService } from './usu.service';

@Module({
  imports: [B3dashSharedModule],
  controllers: [UsuController],
  providers: [UsuService],
})
export class UsuModule {}
