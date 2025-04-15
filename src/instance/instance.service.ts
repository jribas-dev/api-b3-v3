// src/instance/instance.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Instance } from './entities/instance.entity';

@Injectable()
export class InstanceService {
  constructor(
    @InjectRepository(Instance)
    private readonly instanceRepo: Repository<Instance>,
  ) {}

  async create(data: Partial<Instance>): Promise<Instance> {
    const instance = this.instanceRepo.create(data);
    return this.instanceRepo.save(instance);
  }

  async findAll(): Promise<Instance[]> {
    return this.instanceRepo.find();
  }

  async findOneById(dbId: string): Promise<Instance> {
    const instance = await this.instanceRepo.findOneBy({ dbId });
    if (!instance) throw new NotFoundException('Instância não encontrada');
    return instance;
  }

  async update(dbId: string, updates: Partial<Instance>): Promise<Instance> {
    const instance = await this.findOneById(dbId);
    Object.assign(instance, updates);
    return this.instanceRepo.save(instance);
  }
}
