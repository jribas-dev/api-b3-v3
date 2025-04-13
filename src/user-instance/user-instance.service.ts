import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserInstance } from './user-instance.entity';
import { CreateUserInstanceDto } from './dto/user-instance-create.dto';
import { UpdateUserInstanceDto } from './dto/user-instance-update.dto';

@Injectable()
export class UserInstanceService {
  constructor(
    @InjectRepository(UserInstance)
    private readonly userInstanceRepo: Repository<UserInstance>,
  ) {}

  async create(data: CreateUserInstanceDto): Promise<UserInstance> {
    const relation = this.userInstanceRepo.create(data);
    return this.userInstanceRepo.save(relation);
  }

  async findOne(id: number): Promise<UserInstance> {
    const relation = await this.userInstanceRepo.findOne({
      where: { id },
      relations: ['user', 'instance'],
    });
    if (!relation) throw new NotFoundException('Relação não encontrada');
    return relation;
  }

  async findByUser(userId: string): Promise<UserInstance[]> {
    return this.userInstanceRepo.find({
      where: { userId, isActive: true },
      relations: ['instance'],
    });
  }

  async findByDb(dbId: string): Promise<UserInstance[]> {
    return this.userInstanceRepo.find({
      where: { dbId, isActive: true },
      relations: ['user'],
    });
  }

  async update(
    id: number,
    updates: UpdateUserInstanceDto,
  ): Promise<UserInstance> {
    const relation = await this.findOne(id);
    Object.assign(relation, updates);
    return this.userInstanceRepo.save(relation);
  }
}
