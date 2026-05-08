import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, MoreThan, In } from 'typeorm';
import { RefreshTokenEntity } from './refresh-token.entity';
import { randomBytes } from 'crypto';
import { addDays } from 'date-fns';
import { isDate } from 'date-fns';
import { UserInstanceEntity } from 'src/user-domain/user-instance/entities/user-instance.entity';

@Injectable()
export class RefreshTokenService {
  constructor(
    @InjectRepository(RefreshTokenEntity)
    private tokenRepo: Repository<RefreshTokenEntity>,
  ) {}

  async generate(userInstance: UserInstanceEntity, deviceName?: string | null): Promise<string> {
    const token = randomBytes(64).toString('hex');
    const expires = isDate(new Date()) ? addDays(new Date(), 7) : new Date(); // adiciona 7 dias
    expires.setHours(expires.getHours() + 1); // adiciona 1 hora

    await this.tokenRepo.save({
      token,
      userInstance: userInstance,
      expiresAt: expires,
      deviceName: deviceName ?? null,
    });

    return token;
  }

  async findActiveByUserId(userId: string): Promise<Array<{ deviceName: string | null; expiresAt: Date }>> {
    const tokens = await this.tokenRepo.find({
      where: {
        userInstance: { userId },
        isRevoked: false,
        expiresAt: MoreThan(new Date()),
      },
    });
    return tokens.map((t) => ({ deviceName: t.deviceName, expiresAt: t.expiresAt }));
  }

  async revokeAllByUserId(userId: string): Promise<number> {
    const tokens = await this.tokenRepo.find({
      where: {
        userInstance: { userId },
        isRevoked: false,
        expiresAt: MoreThan(new Date()),
      },
      select: ['id'],
    });
    if (tokens.length === 0) return 0;
    const result = await this.tokenRepo.update(
      { id: In(tokens.map((t) => t.id)) },
      { isRevoked: true },
    );
    return result.affected ?? 0;
  }

  async validate(token: string): Promise<RefreshTokenEntity | null> {
    const rt = await this.tokenRepo.findOne({
      where: { token },
      relations: ['userInstance'],
    });

    if (!rt || rt.isRevoked || rt.expiresAt < new Date()) {
      return null;
    }

    return rt;
  }

  async revoke(token: string): Promise<void> {
    await this.tokenRepo.update({ token }, { isRevoked: true });
  }

  async cleanupExpired(): Promise<void> {
    await this.tokenRepo.delete([
      { isRevoked: true },
      { expiresAt: LessThan(new Date()) },
    ]);
  }

}
