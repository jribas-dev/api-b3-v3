export class FinReceberDto {
  idctarec: number;
  cliente: string;
  emissao: string;
  vencimento: string;
  pagamento: string | null;
  valor: number;
  valorpago: number;
  status: 'pago' | 'vencido' | 'aberto';
}
