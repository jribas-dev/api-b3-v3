import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class CreateDomainIdentityDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6}$/, {
    message: 'Domínio inválido',
  })
  domain: string;
}
