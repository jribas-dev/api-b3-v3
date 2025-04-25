import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserInstanceEntity } from './entities/user-instance.entity';
import { CreateUserInstanceDto } from './dto/create-user-instance.dto';
import { UpdateUserInstanceDto } from './dto/update-user-instance.dto';
import { ResponseUserInstanceDto } from './dto/response-user-instance.dto';
import { plainToInstance } from 'class-transformer';

@Injectable()
export class UserInstanceService {
  constructor(
    @InjectRepository(UserInstanceEntity)
    private readonly userInstanceRepo: Repository<UserInstanceEntity>,
  ) {}

  async create(data: CreateUserInstanceDto): Promise<ResponseUserInstanceDto> {
    const newdata = this.userInstanceRepo.create({ ...data, isActive: true });
    const saved = await this.userInstanceRepo.save(newdata);
    return plainToInstance(ResponseUserInstanceDto, saved);
  }

  async findOne(id: number): Promise<ResponseUserInstanceDto> {
    const found = await this.userInstanceRepo.findOne({
      where: { id },
    });
    if (!found) throw new NotFoundException('User instance not found');
    return plainToInstance(ResponseUserInstanceDto, found);
  }

  async findValid(userId: string, dbId: string): Promise<UserInstanceEntity> {
    const found = await this.userInstanceRepo.findOne({
      where: { userId, dbId, isActive: true },
      relations: ['user', 'instance'],
    });
    if (!found) throw new NotFoundException('User instance not found');
    return found;
  }

  async findByUser(userId: string): Promise<ResponseUserInstanceDto[]> {
    const userInstances = await this.userInstanceRepo.find({
      where: { userId, isActive: true },
      relations: ['instance'],
    });
    if (!userInstances || userInstances.length === 0) {
      throw new NotFoundException('No user instances found');
    }
    return userInstances.map((userInstance) =>
      plainToInstance(ResponseUserInstanceDto, userInstance),
    );
  }

  async findByDb(dbId: string): Promise<ResponseUserInstanceDto[]> {
    const usersInstance = await this.userInstanceRepo.find({
      where: { dbId, isActive: true },
      relations: ['user'],
    });
    if (!usersInstance || usersInstance.length === 0) {
      throw new NotFoundException('No user instances found');
    }
    return usersInstance.map((userInstance) =>
      plainToInstance(ResponseUserInstanceDto, userInstance),
    );
  }

  async update(
    id: number,
    updates: UpdateUserInstanceDto,
  ): Promise<ResponseUserInstanceDto> {
    const relation = await this.findOne(id);
    Object.assign(relation, updates);
    const saved = await this.userInstanceRepo.save(relation);
    return plainToInstance(ResponseUserInstanceDto, saved);
  }
}
