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
import { UserEntity } from 'src/user/entities/user.entity';
import { UserInstanceService } from 'src/user-instance/user-instance.service';
import { UserInstanceEntity } from 'src/user-instance/entities/user-instance.entity';
import { BlacklistService } from './black-list/black-list.service';

@Injectable()
export class AuthService {
  constructor(
    @Inject(forwardRef(() => UserService))
    @Inject(forwardRef(() => UserInstanceService))
    private readonly userService: UserService,
    private readonly userInstanceService: UserInstanceService,
    private readonly jwtService: JwtService,
    private readonly refreshTokenService: RefreshTokenService,
    private readonly passwordService: PasswordService,
    private readonly loginAttemptService: LoginAttemptService,
    private readonly blacklistService: BlacklistService,
  ) {}

  async validate(
    email: string,
    password: string,
    req: Request,
  ): Promise<UserEntity> {
    const identifier = this.loginAttemptService.getIdentifier(req);

    // Verifica se a origem está bloqueada
    await this.loginAttemptService.shouldBlock(identifier);

    const user = await this.userService.findOneByEmail(email);
    if (!user) {
      await this.loginAttemptService.registerFailure(identifier);
      throw new UnauthorizedException('Credenciais inválidas');
    }

    const hashedPassword = await this.userService.getHashedPassword(email);
    const passwordValid = await this.passwordService.comparePasswords(
      password,
      hashedPassword,
    );

    if (!passwordValid) {
      await this.loginAttemptService.registerFailure(identifier);
      throw new UnauthorizedException('Credenciais inválidas');
    }

    // Zera as tentativas se validação for bem-sucedida
    await this.loginAttemptService.resetAttempts(identifier);

    return user;
  }

  async validateUserInstance(
    userId: string,
    dbId: string,
  ): Promise<UserInstanceEntity> {
    const userInstance = await this.userInstanceService.findValid(userId, dbId);
    if (!userInstance) {
      throw new UnauthorizedException('Usuário ou instância inválidos');
    }
    return userInstance;
  }

  async login(user: UserEntity) {
    const payload = {
      sub: user.userId,
      email: user.email,
      isRoot: user.isRoot,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      expiresIn: '30m',
    });

    return {
      accessToken,
      tokenType: 'Bearer',
      expiresIn: 1800,
    };
  }

  async loginInstance(userInstance: UserInstanceEntity) {
    const payload = {
      sub: userInstance.userId,
      email: userInstance.user.email,
      isRoot: userInstance.user.isRoot,
      instanceName: userInstance.instance.name,
      dbId: userInstance.dbId,
      roleBack: userInstance.roleback,
      roleFront: userInstance.rolefront,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      expiresIn: '180m',
    });

    const refreshToken = await this.refreshTokenService.generate(userInstance);

    return {
      isActive: userInstance.isActive && userInstance.user.isActive,
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: 10800,
    };
  }

  async refresh(oldToken: string) {
    const tokenData = await this.refreshTokenService.validate(oldToken);

    if (!tokenData) {
      throw new UnauthorizedException('Refresh token inválido ou expirado');
    }

    const user = tokenData.userInstance.user;
    const instance = tokenData.userInstance.instance;

    const payload: JwtPayload = {
      sub: user.userId,
      email: user.email,
      isRoot: user.isRoot,
      instanceName: instance.name,
      dbId: instance.dbId,
      roleBack: tokenData.userInstance.roleback,
      roleFront: tokenData.userInstance.rolefront,
    };

    const newAccessToken = await this.jwtService.signAsync(payload, {
      expiresIn: '180m',
    });

    const newRefreshToken = await this.refreshTokenService.generate(
      tokenData.userInstance,
    );

    await this.refreshTokenService.revoke(oldToken);

    return {
      isActive: user.isActive && tokenData.userInstance.isActive,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      tokenType: 'Bearer',
      expiresIn: 10800,
    };
  }

  async logout(req: Request): Promise<boolean> {
    const authHeader = req.headers.authorization as string;
    const token = authHeader.replace('Bearer ', '').trim();
    const decoded: { exp?: number } | null = this.jwtService.decode(token);

    if (decoded?.exp) {
      const expiresAt = new Date(decoded.exp * 1000);
      await this.blacklistService.addToken(token, expiresAt);
    }

    return true;
  }
}
