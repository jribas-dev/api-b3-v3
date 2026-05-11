import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserEntity } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { ResponseUserDto } from './dto/response-user.dto';
import { plainToInstance } from 'class-transformer';
import { UpdateUserDto } from './dto/update-user.dto';
import { PasswordService } from 'src/auth/password/password.service';
import { TemplateType } from 'src/infra/aws-ses/sender/enums/template-type.enum';
import { AwsSenderService } from 'src/infra/aws-ses/sender/sender.service';
import { UserInstanceEntity } from 'src/user-domain/user-instance/entities/user-instance.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(UserInstanceEntity)
    private readonly userInstanceRepo: Repository<UserInstanceEntity>,
    private readonly passwordService: PasswordService,
    private readonly senderService: AwsSenderService,
  ) {}

  async create(
    userData: CreateUserDto,
    userInviteId?: string | null,
  ): Promise<ResponseUserDto> {
    const user = this.userRepo.create({
      ...userData,
      password: await this.passwordService.hashPassword(userData.password),
      userInviteId: userInviteId ?? null,
    });
    const savedUser = await this.userRepo.save(user);

    // Send welcome email
    await this.senderService.sendTemplateEmail(
      savedUser.email,
      'Bem-vindo ao sistema B3Erp',
      TemplateType.WELCOME,
      { name: savedUser.name },
    );

    return plainToInstance(ResponseUserDto, savedUser);
  }

  async findAll(): Promise<ResponseUserDto[]> {
    const users = await this.userRepo.find();
    if (!users || users.length === 0) {
      throw new NotFoundException('Nenhum usuário encontrado');
    }
    return users.map((user) => plainToInstance(ResponseUserDto, user));
  }

  async findInvitedNotInInstance(
    inviterUserId: string,
    dbId: string,
  ): Promise<ResponseUserDto[]> {
    const users = await this.userRepo
      .createQueryBuilder('user')
      .where('user.userInviteId = :inviterUserId', { inviterUserId })
      .andWhere((qb) => {
        const sub = qb
          .subQuery()
          .select('1')
          .from(UserInstanceEntity, 'ui')
          .where('ui.userId = user.userId')
          .andWhere('ui.dbId = :dbId')
          .getQuery();
        return `NOT EXISTS ${sub}`;
      })
      .setParameter('dbId', dbId)
      .getMany();
    return users.map((user) => plainToInstance(ResponseUserDto, user));
  }

  async findOneById(userId: string): Promise<ResponseUserDto> {
    const user = await this.userRepo.findOneBy({ userId });
    if (!user) throw new NotFoundException('Usuário não encontrado');
    return plainToInstance(ResponseUserDto, user);
  }

  async findOneByEmail(email: string | undefined): Promise<UserEntity | null> {
    const user = await this.userRepo.findOneBy({ email });
    if (!user) return null;
    return user;
  }

  async getHashedPassword(email: string): Promise<string> {
    const user = await this.userRepo.findOne({
      where: { email },
      select: ['password'],
    });
    return user?.password || '';
  }

  async findOneByPhone(phone: string | undefined): Promise<UserEntity | null> {
    const user = await this.userRepo.findOneBy({ phone });
    if (!user) return null;
    return user;
  }

  async update(
    userId: string,
    updates: Partial<UpdateUserDto>,
  ): Promise<ResponseUserDto> {
    const user = await this.userRepo.findOneBy({ userId });
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }
    if (updates.name !== undefined) user.name = updates.name;
    if (updates.email !== undefined) user.email = updates.email;
    if (updates.phone !== undefined) user.phone = updates.phone;
    if (updates.password !== undefined) {
      user.password = await this.passwordService.hashPassword(updates.password);
    }
    const updatedUser = await this.userRepo.save(user);
    return plainToInstance(ResponseUserDto, updatedUser);
  }

  async setActive(userId: string, isActive: boolean): Promise<ResponseUserDto> {
    const user = await this.userRepo.findOneBy({ userId });
    if (!user) throw new NotFoundException('Usuário não encontrado');
    user.isActive = isActive;
    const saved = await this.userRepo.save(user);
    if (!isActive) {
      await this.userInstanceRepo.update({ userId }, { isActive: false });
    }
    return plainToInstance(ResponseUserDto, saved);
  }

  async delete(userId: string): Promise<void> {
    const user = await this.findOneById(userId);
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }
    await this.userRepo.delete(userId);
  }
}
