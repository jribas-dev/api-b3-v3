export class FinPagarDto {
  idpag: number;
  nrodoc: string | null;
  fornecedor: string;
  emissao: string;
  vencimentoMin: string | null;
  valortotal: number;
  valorPagoAcum: number;
  status: 'pago' | 'vencido' | 'aberto';
}
