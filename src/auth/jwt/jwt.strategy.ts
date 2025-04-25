import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { JwtPayload } from 'src/auth/jwt/jwt.payload.interface';
import { BlacklistService } from '../black-list/black-list.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private config: ConfigService,
    private blacklistService: BlacklistService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        config.get<string>('JWT_SECRET') || 'SePrecisouDissoAquiTaErrado',
      passReqToCallback: true,
    });
  }

  async validate(req: Request, payload: JwtPayload) {
    const token = ExtractJwt.fromAuthHeaderAsBearerToken()(req);
    if (!token) {
      throw new UnauthorizedException(
        'Token não encontrado no cabeçalho de autorização',
      );
    }
    const isBlacklisted = await this.blacklistService.isBlacklisted(token);

    if (isBlacklisted) {
      throw new UnauthorizedException('Token inválido ou expirado');
    }
    return {
      userId: payload.sub,
      email: payload.email,
      isRoot: payload.isRoot,
      instanceName: payload.instanceName,
      dbId: payload.dbId,
    };
  }
}
