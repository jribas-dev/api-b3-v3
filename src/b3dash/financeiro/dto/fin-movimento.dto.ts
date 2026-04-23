export class FinMovimentoDto {
  idmov: number;
  dataemi: string;
  debcred: 'C' | 'D';
  especie: string;
  destino: string;
  valor: number;
  baixado: boolean;
  tborigem: string | null;
}
