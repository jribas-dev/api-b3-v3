import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class CheckIdentityDto {
  @IsString()
  @IsNotEmpty()
  @Matches(
    /^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|((?!-)[A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,6})$/,
  )
  identity: string;
}
