// src/instance/instance.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InstanceEntity } from './entities/instance.entity';
import { CreateInstanceDto } from './dto/create-instance.dto';
import { ResponseInstanceDto } from './dto/response-instance.dto';
import { plainToInstance } from 'class-transformer';
import { UpdateInstanceDto } from './dto/update-instance.dto';
import { UserInstanceEntity } from 'src/user-domain/user-instance/entities/user-instance.entity';
import { TenantService } from 'src/tenant/tenant.service';

@Injectable()
export class InstanceService {
  constructor(
    @InjectRepository(InstanceEntity)
    private readonly instanceRepo: Repository<InstanceEntity>,
    @InjectRepository(UserInstanceEntity)
    private readonly userInstanceRepo: Repository<UserInstanceEntity>,
    private readonly tenantService: TenantService,
  ) {}

  async create(data: Partial<CreateInstanceDto>): Promise<ResponseInstanceDto> {
    const newInstance = this.instanceRepo.create(data);
    const saved = await this.instanceRepo.save(newInstance);
    return plainToInstance(ResponseInstanceDto, saved);
  }

  async findAll(): Promise<ResponseInstanceDto[]> {
    const instances = await this.instanceRepo.find();
    if (!instances.length)
      throw new NotFoundException('Nenhuma instância encontrada');
    return instances.map((instance) =>
      plainToInstance(ResponseInstanceDto, instance),
    );
  }

  async findOneById(dbId: string): Promise<ResponseInstanceDto> {
    const instance = await this.instanceRepo.findOneBy({ dbId });
    if (!instance) throw new NotFoundException('Instância não encontrada');
    return plainToInstance(ResponseInstanceDto, instance);
  }

  async update(
    dbId: string,
    updates: Partial<UpdateInstanceDto>,
  ): Promise<ResponseInstanceDto> {
    const instance = await this.instanceRepo.findOneBy({ dbId });
    if (!instance) throw new NotFoundException('Instância não encontrada');

    if (updates.name !== undefined) instance.name = updates.name;
    if (updates.dbName !== undefined) instance.dbName = updates.dbName;
    if (updates.dbHost !== undefined) instance.dbHost = updates.dbHost;
    if (updates.maxCompanies !== undefined) instance.maxCompanies = updates.maxCompanies;
    if (updates.maxUsers !== undefined) instance.maxUsers = updates.maxUsers;
    if (updates.isActive !== undefined) instance.isActive = updates.isActive;

    const updatedInstance = await this.instanceRepo.save(instance);

    // se a instancia esta inativa, deve inativar todos os usuarios associados
    if (updatedInstance.isActive === false) {
      await this.userInstanceRepo.update(
        { dbId: updatedInstance.dbId },
        { isActive: false },
      );
    }

    // evict cached DataSource if pool-relevant fields changed
    if (
      updates.maxUsers !== undefined ||
      updates.dbHost !== undefined ||
      updates.dbName !== undefined
    ) {
      await this.tenantService.evictDataSource(dbId);
    }

    return plainToInstance(ResponseInstanceDto, updatedInstance);
  }
}
