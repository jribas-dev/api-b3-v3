import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { InstanceEntity } from 'src/user-domain/instance/entities/instance.entity';
import { TENANT_ENTITIES } from './tenant-entities';

@Injectable()
export class TenantService implements OnModuleDestroy {
  private readonly logger = new Logger(TenantService.name);
  private readonly connections = new Map<string, DataSource>();

  constructor(
    @InjectRepository(InstanceEntity)
    private readonly instanceRepo: Repository<InstanceEntity>,
    private readonly configService: ConfigService,
  ) {}

  async getDataSource(dbId: string): Promise<DataSource> {
    const cached = this.connections.get(dbId);

    if (cached) {
      if (cached.isInitialized) {
        return cached;
      }
      this.logger.warn(
        `Tenant "${dbId}" — stale connection detected, recreating`,
      );
      this.connections.delete(dbId);
    }

    const inst = await this.instanceRepo.findOneOrFail({
      where: { dbId },
    });

    const ds = new DataSource({
      type: 'mysql',
      host: inst.dbHost,
      port: this.configService.get<number>('DB_PORT'),
      username: this.configService.get('DB_USERNAME'),
      password: this.configService.get('DB_PASSWORD'),
      database: inst.dbName,
      entities: TENANT_ENTITIES,
      synchronize: false,
      extra: {
        connectionLimit: inst.maxUsers,
        waitForConnections: true,
        queueLimit: 0,
      },
    });

    await ds.initialize();
    this.connections.set(dbId, ds);

    this.logger.log(
      `Tenant "${dbId}" connected → ${inst.dbHost}/${inst.dbName} (pool: ${inst.maxUsers})`,
    );

    return ds;
  }

  async evictDataSource(dbId: string): Promise<void> {
    const ds = this.connections.get(dbId);
    if (!ds) return;

    this.connections.delete(dbId);

    if (ds.isInitialized) {
      await ds.destroy();
    }

    this.logger.log(`Tenant "${dbId}" evicted from pool cache`);
  }

  async onModuleDestroy(): Promise<void> {
    const count = this.connections.size;
    if (count === 0) return;

    this.logger.log(`Closing ${count} tenant connection(s)...`);

    const results = await Promise.allSettled(
      Array.from(this.connections.entries()).map(async ([dbId, ds]) => {
        if (ds.isInitialized) {
          await ds.destroy();
        }
        return dbId;
      }),
    );

    for (const result of results) {
      if (result.status === 'rejected') {
        this.logger.error(
          `Failed to close tenant connection: ${result.reason}`,
        );
      }
    }

    this.connections.clear();
    this.logger.log('All tenant connections closed');
  }
}
