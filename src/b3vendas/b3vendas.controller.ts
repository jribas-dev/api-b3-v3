import {
  Controller,
  Get,
  NotFoundException,
  Param,
  ParseIntPipe,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { TenantService } from './tenant/tenant.service';
import { PessoaEntity } from './entities/pessoa.entity';

@Controller('b3vendas')
@UseGuards(JwtGuard, UserInstanceGuard)
export class B3vendasController {
  constructor(private tenantService: TenantService) {}

  @Get('info/pessoa/:id')
  async getInfoPessoa(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) id: number,
  ) {
    const ds = await this.tenantService.getDataSource(req.user.dbId);
    const pessoaRepo = ds.getRepository(PessoaEntity);
    const pessoa = await pessoaRepo.findOneBy({ id });
    if (!pessoa) {
      throw new NotFoundException(`Pessoa não encontrada ${id}`);
    }
    return pessoa;
  }
}
