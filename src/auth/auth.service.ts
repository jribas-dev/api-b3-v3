import {
  Injectable,
  UnauthorizedException,
  ForbiddenException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { CfgService } from 'src/tenant/cfg.service';
import { JwtService } from '@nestjs/jwt';
import { UserService } from 'src/user-domain/user/user.service';
import { PasswordService } from './password/password.service';
import { RefreshTokenService } from './refresh-token/refresh-token.service';
import { LoginAttemptService } from './login-attempt/login-attempt.service';
import { JwtPayload } from './jwt/jwt.payload.interface';
import { Request } from 'express';
import { UserEntity } from 'src/user-domain/user/entities/user.entity';
import { UserInstanceService } from 'src/user-domain/user-instance/user-instance.service';
import { UserInstanceEntity } from 'src/user-domain/user-instance/entities/user-instance.entity';
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
    private readonly cfgService: CfgService,
    private readonly configService: ConfigService,
  ) {}

  async validate(
    email: string,
    password: string,
    req: Request,
  ): Promise<UserEntity> {
    const identifier = this.loginAttemptService.getIdentifier(req, email);

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

    const minVersion = this.configService.get<string>('MIN_TENANT_DB', '2.38');
    const cfg = await this.cfgService.find(dbId, 'VERSAO_DB');
    if (cfg && this.compareVersions(cfg.valor, minVersion) < 0) {
      throw new ForbiddenException(
        `Versão do banco do tenant (${cfg.valor}) inferior à mínima exigida (${minVersion}).`,
      );
    }

    return userInstance;
  }

  private compareVersions(a: string, b: string): number {
    const pa = a.split('.').map(Number);
    const pb = b.split('.').map(Number);
    const len = Math.max(pa.length, pb.length);
    for (let i = 0; i < len; i++) {
      const diff = (pa[i] ?? 0) - (pb[i] ?? 0);
      if (diff !== 0) return diff;
    }
    return 0;
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
