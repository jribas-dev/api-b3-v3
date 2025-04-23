import { IsOptional, IsInt, Min, Max } from 'class-validator';

export class ListIdentitiesDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(1000)
  pageSize?: number = 100;

  @IsOptional()
  nextToken?: string;
}
