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

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    private readonly passwordService: PasswordService,
    private readonly senderService: AwsSenderService,
  ) {}

  async create(userData: CreateUserDto): Promise<ResponseUserDto> {
    const user = this.userRepo.create({
      ...userData,
      password: await this.passwordService.hashPassword(userData.password),
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
    const user = await this.findOneById(userId);
    Object.assign(user, updates);
    const updatedUser = await this.userRepo.save(user);
    return plainToInstance(ResponseUserDto, updatedUser);
  }
}
