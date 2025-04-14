import {
  Injectable,
  UnauthorizedException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from 'src/user/user.service';
import { PasswordService } from './password/password.service';
import { RefreshTokenService } from './refresh-token/refresh-token.service';
import { LoginAttemptService } from './login-attempt/login-attempt.service';
import { JwtPayload } from './jwt/jwt.payload.interface';
import { Request } from 'express';
import { User } from 'src/user/user.entity';

@Injectable()
export class AuthService {
  constructor(
    @Inject(forwardRef(() => UserService))
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly refreshTokenService: RefreshTokenService,
    private readonly passwordService: PasswordService,
    private readonly loginAttemptService: LoginAttemptService,
  ) {}

  async validate(email: string, password: string, req: Request): Promise<User> {
    const identifier = this.loginAttemptService.getIdentifier(req);

    // Verifica se a origem está bloqueada
    await this.loginAttemptService.shouldBlock(identifier);

    const user = await this.userService.findOneByEmail(email);

    if (!user || !user.isActive) {
      await this.loginAttemptService.registerFailure(identifier);
      throw new UnauthorizedException('Credenciais inválidas');
    }

    const passwordValid = await this.passwordService.comparePasswords(
      password,
      user.password,
    );

    if (!passwordValid) {
      await this.loginAttemptService.registerFailure(identifier);
      throw new UnauthorizedException('Credenciais inválidas');
    }

    // Zera as tentativas se login for bem-sucedido
    await this.loginAttemptService.resetAttempts(identifier);

    return user;
  }

  async login(user: User) {
    const payload = {
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
      expiresIn: 3600,
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
