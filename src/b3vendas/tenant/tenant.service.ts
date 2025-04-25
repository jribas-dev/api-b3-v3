// tenant.service.ts
import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { InstanceEntity } from 'src/instance/entities/instance.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { PessoaEntity } from '../entities/pessoa.entity';

@Injectable()
export class TenantService {
  private connections = new Map<string, DataSource>();

  constructor(
    @InjectRepository(InstanceEntity)
    private instanceRepo: Repository<InstanceEntity>,
    private readonly configService: ConfigService,
  ) {}

  async getDataSource(dbId: string): Promise<DataSource> {
    if (this.connections.has(dbId)) {
      return this.connections.get(dbId)!;
    }

    // busca credenciais e host/dbname no banco principal
    const inst = await this.instanceRepo.findOneOrFail({
      where: { dbId },
    });

    // define aqui **exatamente** as entities que existem nesse banco de tenant
    // você pode usar um array de classes:
    const entities = [
      // join(__dirname, 'entities', '*.entity{.ts,.js}'),
      // __dirname + '/../orders/entities/*.entity{.ts,.js}',
      // ou explicitamente: Product, Order, etc
      PessoaEntity,
    ];

    const ds = new DataSource({
      type: 'mysql',
      host: inst.dbHost,
      port: this.configService.get<number>('DB_PORT'),
      username: this.configService.get('DB_USERNAME'),
      password: this.configService.get('DB_PASSWORD'),
      database: inst.dbName,
      entities,
      synchronize: false,
    });

    await ds.initialize();
    this.connections.set(dbId, ds);
    return ds;
  }
}
