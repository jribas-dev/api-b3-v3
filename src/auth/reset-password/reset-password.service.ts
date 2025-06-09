import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from 'src/user/entities/user.entity';
import { Repository } from 'typeorm';
import { ResetPasswordEntity } from './reset-password.entity';
import { AwsSenderService } from 'src/infra/aws-ses/sender/sender.service';
import { TemplateType } from 'src/infra/aws-ses/sender/enums/template-type.enum';
import { randomBytes } from 'crypto';
import { PasswordService } from '../password/password.service';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class ResetPasswordService {
  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(ResetPasswordEntity)
    private readonly resetRepo: Repository<ResetPasswordEntity>,
    private readonly emailService: AwsSenderService,
    private readonly passwordService: PasswordService,
    private readonly configService: ConfigService,
  ) {}

  async requestPasswordReset(email: string) {
    const user = await this.userRepo.findOne({
      where: { email },
    });
    if (!user) throw new NotFoundException('User not found');
    if (!user.isActive)
      throw new NotFoundException('Invalid user, call support');

    const token = randomBytes(88).toString('hex');
    const expiresAt = new Date(Date.now() + 1000 * 60 * 60); // 1 hora de expiração
    const newReset = this.resetRepo.create({ user, token, expiresAt });
    await this.resetRepo.save(newReset);

    const frontUrl = this.configService.get<string>('FRONTEND_URL');
    const resetLink = `${frontUrl}/auth/reset-password/?token=${token}&email=${user.email}`;

    await this.emailService.sendTemplateEmail(
      user.email,
      'Redefinição de senha',
      TemplateType.PASSWORD_RESET,
      { name: user.name, resetLink },
    );

    return {
      success: true,
      message: 'Password reset email sent, you have 1 hour to reset it.',
      email: user.email,
      token: token,
    };
  }

  async checkToken(token: string, email: string) {
    const user = await this.userRepo.findOne({
      where: { email },
    });
    if (!user) throw new NotFoundException('User not found');
    if (!user.isActive)
      throw new NotFoundException('Invalid user, call support');

    const resetEntity = await this.resetRepo.findOne({
      where: { token, user },
    });
    if (!resetEntity) throw new NotFoundException('Token not found');
    if (resetEntity.expiresAt < new Date())
      throw new NotFoundException('Token expired');

    return resetEntity;
  }

  async updatePassword(token: string, email: string, newPassword: string) {
    const resetEntity = await this.checkToken(token, email);
    const user = resetEntity.user;

    user.password = await this.passwordService.hashPassword(newPassword);

    await this.userRepo.save(user);
    await this.resetRepo.delete(resetEntity.id);

    return user;
  }
}
