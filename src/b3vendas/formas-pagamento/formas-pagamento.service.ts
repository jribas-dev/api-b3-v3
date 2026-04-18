import { Injectable, NotFoundException } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { TenantService } from 'src/tenant/tenant.service';
import { FormaPagamentoEntity } from './entities/forma-pagamento.entity';
import { ResponseFormaDto } from './dto/response-forma.dto';

type FormaRow = { idforma: number; nmforma: string };
type CondRow = { idcond: number; nomecond: string };

@Injectable()
export class FormasPagamentoService {
  constructor(private readonly tenantService: TenantService) {}

  async formasDisponiveisParaCliente(
    dbId: string,
    idCli: number,
  ): Promise<ResponseFormaDto[]> {
    const ds = await this.tenantService.getDataSource(dbId);
    const rows = await ds.query<FormaRow[]>(
      `SELECT DISTINCT tab.* FROM (
          SELECT a.id AS idforma, a.nmforma
            FROM formapg a
           WHERE a.id IN (SELECT idforma FROM cnt WHERE id = ?)
          UNION ALL
          SELECT DISTINCT a.id AS idforma, a.nmforma
            FROM venda v
            INNER JOIN vendacaixa c ON c.idvenda = v.id
            INNER JOIN formapg    a ON a.id = c.idforma
           WHERE v.idcli = ?
        ) tab
        ORDER BY 1`,
      [idCli, idCli],
    );

    return rows.map((r) =>
      plainToInstance(ResponseFormaDto, { id: r.idforma, nome: r.nmforma }),
    );
  }

  async condicoesDisponiveisParaCliente(
    dbId: string,
    idCli: number,
  ): Promise<ResponseFormaDto[]> {
    const ds = await this.tenantService.getDataSource(dbId);
    const rows = await ds.query<CondRow[]>(
      `SELECT DISTINCT tab.* FROM (
          SELECT a.idcond, a.nomecond
            FROM condpg a
           WHERE a.idcond IN (SELECT idcond FROM cnt WHERE id = ?)
          UNION ALL
          SELECT DISTINCT a.idcond, a.nomecond
            FROM venda v
            INNER JOIN vendacaixa c ON c.idvenda = v.id
            INNER JOIN condpg     a ON a.idcond  = c.idcond
           WHERE v.idcli = ?
        ) tab
        ORDER BY 1`,
      [idCli, idCli],
    );

    return rows.map((r) =>
      plainToInstance(ResponseFormaDto, { id: r.idcond, nome: r.nomecond }),
    );
  }

  async operacaoDaForma(dbId: string, idForma: number): Promise<string> {
    const ds = await this.tenantService.getDataSource(dbId);
    const forma = await ds
      .getRepository(FormaPagamentoEntity)
      .findOneBy({ id: idForma });
    if (!forma) throw new NotFoundException(`Forma ${idForma} não encontrada`);
    return forma.operacao;
  }
}
