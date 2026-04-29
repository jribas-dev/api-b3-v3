import { Exclude, Expose } from 'class-transformer';
import { ResponseClienteInfoDto } from 'src/b3vendas/cliente/dto/response-cliente-info.dto';

@Exclude()
export class ResponseVendaResumoDto {
  @Expose()
  id: number;

  @Expose()
  idcli: number | null;

  @Expose()
  razaoCliente: string | null;

  @Expose()
  dthremissao: Date;

  @Expose()
  tipo: string;

  @Expose()
  vlrtotal: number;
}

@Exclude()
export class ResponseVendaItemDto {
  @Expose()
  seq: number;

  @Expose()
  idprod: number;

  @Expose()
  nomeProduto: string | null;

  @Expose()
  qtde: number;

  @Expose()
  unitario: number;

  @Expose()
  total: number;
}

@Exclude()
export class ResponseVendaDetalheDto {
  @Expose()
  id: number;

  @Expose()
  idcli: number | null;

  @Expose()
  razaoCliente: string | null;

  @Expose()
  idoper: number;

  @Expose()
  fiscal: string;

  @Expose()
  tipo: string;

  @Expose()
  vlrbruto: number;

  @Expose()
  desconto: number;

  @Expose()
  acrescimo: number;

  @Expose()
  st: number;

  @Expose()
  ipi: number;

  @Expose()
  vlrtotal: number;

  @Expose()
  obsinter: string | null;

  @Expose()
  idForma: number | null;

  @Expose()
  idCond: number | null;

  @Expose()
  itens: ResponseVendaItemDto[];

  @Expose()
  cliente: ResponseClienteInfoDto | null;
}
