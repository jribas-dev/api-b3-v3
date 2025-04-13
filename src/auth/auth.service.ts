import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

import { User } from 'src/user/user.entity';
import { JwtPayload } from 'src/auth/jwt/jwt.payload.interface';
import { RefreshTokenService } from './refresh-token/refresh-token.service';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepo: Repository<User>,
    private jwtService: JwtService,
    private refreshTokenService: RefreshTokenService,
  ) {}

  async validateUser(email: string, password: string): Promise<User> {
    const user = await this.userRepo.findOne({ where: { email } });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Usuário inválido ou inativo');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Dados não conferem');
    }

    return user;
  }

  async login(user: User) {
    // const user = await this.validateUser(email, password);

    const payload: JwtPayload = {
      sub: user.userId,
      email: user.email,
      isRoot: user.isRoot,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      expiresIn: '60m',
    });

    const refreshToken = await this.refreshTokenService.generate(user);

    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: 3600, // 60 min
    };
  }

  async refresh(oldToken: string) {
    const tokenData = await this.refreshTokenService.validate(oldToken);

    if (!tokenData) {
      throw new UnauthorizedException('Refresh token inválido ou expirado');
    }

    const user = tokenData.user;

    const payload: JwtPayload = {
      sub: user.userId,
      email: user.email,
      isRoot: user.isRoot,
    };

    const newAccessToken = await this.jwtService.signAsync(payload, {
      expiresIn: '60m',
    });

    const newRefreshToken = await this.refreshTokenService.generate(user);

    await this.refreshTokenService.revoke(oldToken);

    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      tokenType: 'Bearer',
      expiresIn: 3600,
    };
  }
}
