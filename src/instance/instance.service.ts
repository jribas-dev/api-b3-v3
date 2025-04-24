// src/instance/instance.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InstanceEntity } from './entities/instance.entity';
import { CreateInstanceDto } from './dto/create-instance.dto';
import { ResponseInstanceDto } from './dto/response-instance.dto';
import { plainToInstance } from 'class-transformer';
import { UpdateInstanceDto } from './dto/update-instance.dto';

@Injectable()
export class InstanceService {
  constructor(
    @InjectRepository(InstanceEntity)
    private readonly instanceRepo: Repository<InstanceEntity>,
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
    const instance = await this.findOneById(dbId);
    Object.assign(instance, updates);
    const updatedInstance = await this.instanceRepo.save(instance);
    return plainToInstance(ResponseInstanceDto, updatedInstance);
  }
}
