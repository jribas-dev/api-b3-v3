import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt/jwt.strategy';
import { JwtGuard } from './guards/jwt.guard';
import { RootGuard } from './guards/root.guard';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from 'src/user/user.entity';
import { RefreshToken } from './refresh-token/refresh-token.entity';
import { RefreshTokenService } from './refresh-token/refresh-token.service';
import { LoginAttemptService } from './login-attempt.service';
import { BlacklistModule } from './black-list/black-list.module';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([User, RefreshToken]),
    PassportModule,
    // JwtModule.register({
    //   secret: process.env.JWT_SECRET || 'fallbackSecret',
    //   signOptions: { expiresIn: '60m' },
    // }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.get<string>('JWT_SECRET');
        return {
          global: true,
          secret: secret || 'SePrecisouDissoAquiTaErrado',
          signOptions: { expiresIn: '60m' },
        };
      },
    }),
    BlacklistModule,
  ],
  providers: [
    AuthService,
    JwtStrategy,
    JwtGuard,
    RootGuard,
    RefreshTokenService,
    LoginAttemptService,
  ],
  controllers: [AuthController],
  exports: [AuthService],
})
export class AuthModule {}
