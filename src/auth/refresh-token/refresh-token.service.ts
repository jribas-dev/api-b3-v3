import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RefreshToken } from './refresh-token.entity';
import { User } from 'src/user/user.entity';
import { randomBytes } from 'crypto';
import { addDays } from 'date-fns';
import { isDate } from 'date-fns';

@Injectable()
export class RefreshTokenService {
  constructor(
    @InjectRepository(RefreshToken)
    private tokenRepo: Repository<RefreshToken>,
  ) {}

  async generate(user: User): Promise<string> {
    const token = randomBytes(64).toString('hex');
    const expires = isDate(new Date()) ? addDays(new Date(), 7) : new Date(); // token válido por 7 dias

    await this.tokenRepo.save({
      token,
      user,
      expiresAt: expires,
    });

    return token;
  }

  async validate(token: string): Promise<RefreshToken | null> {
    const rt = await this.tokenRepo.findOne({
      where: { token },
      relations: ['user'],
    });

    if (!rt || rt.isRevoked || rt.expiresAt < new Date()) {
      return null;
    }

    return rt;
  }

  async revoke(token: string): Promise<void> {
    await this.tokenRepo.update({ token }, { isRevoked: true });
  }

  // async revokeall(uId: string): Promise<void> {
  //   await this.tokenRepo.update({ user: { userId: uId } }, { isRevoked: true });
  // }
}
