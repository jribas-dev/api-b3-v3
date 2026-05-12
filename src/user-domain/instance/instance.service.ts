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
import {
  RoleBack,
  RoleFrontEnum,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { UserEntity } from 'src/user-domain/user/entities/user.entity';
import { TenantService } from 'src/tenant/tenant.service';

const BUILTIN_USER_INSTANCES = [
  {
    email: 'admin@b3erp.com.br',
    roleback: RoleBack.ADMIN,
    rolefront: [
      RoleFrontEnum.ADMIN,
      RoleFrontEnum.SUPERSALER,
      RoleFrontEnum.INVENTORY,
      RoleFrontEnum.BUYER,
    ],
    idBackendUser: 1,
  },
  {
    email: 'super@b3erp.com.br',
    roleback: RoleBack.SUPER,
    rolefront: [
      RoleFrontEnum.ADMIN,
      RoleFrontEnum.SUPERSALER,
      RoleFrontEnum.INVENTORY,
    ],
    idBackendUser: 2,
  },
] as const;

@Injectable()
export class InstanceService {
  constructor(
    @InjectRepository(InstanceEntity)
    private readonly instanceRepo: Repository<InstanceEntity>,
    @InjectRepository(UserInstanceEntity)
    private readonly userInstanceRepo: Repository<UserInstanceEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly tenantService: TenantService,
  ) {}

  async create(data: Partial<CreateInstanceDto>): Promise<ResponseInstanceDto> {
    const newInstance = this.instanceRepo.create(data);
    const saved = await this.instanceRepo.save(newInstance);
    await this.attachBuiltInUsers(saved.dbId);
    return plainToInstance(ResponseInstanceDto, saved);
  }

  private async attachBuiltInUsers(dbId: string): Promise<void> {
    for (const cfg of BUILTIN_USER_INSTANCES) {
      const user = await this.userRepo.findOneBy({ email: cfg.email });
      if (!user) continue;
      const link = this.userInstanceRepo.create({
        userId: user.userId,
        dbId,
        idBackendUser: cfg.idBackendUser,
        roleback: cfg.roleback,
        rolefront: [...cfg.rolefront],
        isActive: true,
      });
      await this.userInstanceRepo.save(link);
    }
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
    if (updates.maxCompanies !== undefined)
      instance.maxCompanies = updates.maxCompanies;
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
