import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async create(userData: Partial<User>): Promise<User> {
    const user = this.userRepo.create(userData);
    return this.userRepo.save(user);
  }

  async findAll(): Promise<User[]> {
    return this.userRepo.find();
  }

  async findOneById(userId: string): Promise<User> {
    const user = await this.userRepo.findOneBy({ userId });
    if (!user) throw new NotFoundException('Usuário não encontrado');
    return user;
  }

  async findOneByEmail(email: string | undefined): Promise<User | null> {
    const user = await this.userRepo.findOneBy({ email });
    return user;
  }

  async findOneByPhone(phone: string): Promise<User | null> {
    const user = await this.userRepo.findOneBy({ phone });
    return user;
  }

  async update(userId: string, updates: Partial<User>): Promise<User> {
    const user = await this.findOneById(userId);
    Object.assign(user, updates);
    return this.userRepo.save(user);
  }
}
