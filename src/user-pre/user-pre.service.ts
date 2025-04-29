import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { UserPreEntity } from './entities/user-pre.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserPreDto } from './dto/create-user-pre.dto';
import { randomBytes } from 'crypto';
import { CheckUserPreDto } from './dto/check-user-pre.dto';
import { UserPreInstanceEntity } from './entities/user-pre-instances.entity';
import { UserService } from 'src/user/user.service';
import { CreateUserDto } from 'src/user/dto/create-user.dto';
import { AwsSenderService } from 'src/infra/aws-ses/sender/sender.service';
import { TemplateType } from 'src/infra/aws-ses/sender/enums/template-type.enum';
import { ResponseUserDto } from 'src/user/dto/response-user.dto';
import { plainToInstance } from 'class-transformer';
import { UserInstanceService } from 'src/user-instance/user-instance.service';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class UserPreService {
  constructor(
    @InjectRepository(UserPreEntity)
    private readonly userPreRepo: Repository<UserPreEntity>,
    @InjectRepository(UserPreInstanceEntity)
    private readonly userPreInstanceRepo: Repository<UserPreInstanceEntity>,
    private readonly userService: UserService,
    private readonly userInstanceService: UserInstanceService,
    private readonly senderService: AwsSenderService,
    private readonly configService: ConfigService,
  ) {}

  async create(data: CreateUserPreDto): Promise<UserPreEntity> {
    const existingUser = await this.userService.findOneByEmail(data.email);
    if (existingUser) {
      throw new UnauthorizedException('User already exists');
    }
    const existingUserPre = await this.userPreRepo.findOne({
      where: { email: data.email },
    });
    if (existingUserPre) {
      if (existingUserPre.expiresAt > new Date()) {
        throw new UnauthorizedException('User already exists');
      } else {
        await this.userPreRepo.delete(existingUserPre.userPreId);
      }
    }
    // Create a new user pre with a token and expiration date
    const userPre = this.userPreRepo.create({
      email: data.email,
      token: randomBytes(88).toString('hex'),
      expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 12), // 12 hours
    });
    const newUserPre = await this.userPreRepo.save(userPre);
    for (const { dbId, roleBack, roleFront } of data.dblist) {
      const userPreInstance = this.userPreInstanceRepo.create();
      userPreInstance.userPreId = newUserPre.userPreId;
      userPreInstance.dbId = dbId;
      userPreInstance.roleback = roleBack;
      userPreInstance.rolefront = roleFront;
      await this.userPreInstanceRepo.save(userPreInstance);
    }
    // Send email with the token
    const frontUrl = this.configService.get<string>('FRONTEND_URL');
    const newUserLink = `${frontUrl}/user-pre/confirm/?token=${userPre.token}&email=${data.email}`;

    await this.senderService.sendTemplateEmail(
      data.email,
      'Efetivação de conta',
      TemplateType.NEWUSER_CALL,
      { name: data.email, newUserLink },
    );

    return newUserPre;
  }

  async checkUserPre(data: CheckUserPreDto): Promise<UserPreEntity> {
    const userPre = await this.userPreRepo.findOne({
      where: { email: data.email, token: data.token },
    });
    if (!userPre) {
      throw new NotFoundException('User not found');
    }
    if (userPre.expiresAt < new Date()) {
      await this.userPreRepo.delete(userPre.userPreId);
      throw new UnauthorizedException('Your token has expired');
    }
    return userPre;
  }

  async confirmUser(
    data: CreateUserDto,
    check: CheckUserPreDto,
  ): Promise<ResponseUserDto> {
    if (check.email.trim() !== data.email.trim()) {
      throw new UnauthorizedException('Email does not match token');
    }
    const userPre = await this.checkUserPre(check);
    const userPreInstances = await this.userPreInstanceRepo.find({
      where: { userPreId: userPre.userPreId },
    });
    const user = await this.userService.create(data);
    for (const userPreInstance of userPreInstances) {
      await this.userInstanceService.addUserInstance({
        userId: user.userId,
        dbId: userPreInstance.dbId,
        roleback: userPreInstance.roleback,
        rolefront: userPreInstance.rolefront,
        isActive: true,
      });
    }
    await this.userPreRepo.delete(userPre.userPreId);
    return plainToInstance(ResponseUserDto, user);
  }
}
