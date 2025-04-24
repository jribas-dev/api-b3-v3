import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class RelationInstanceDto {
  @Expose()
  name: string;

  @Expose()
  dbName: string;

  @Expose()
  dbHost: string;
}
