import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt/jwt.strategy';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RefreshTokenEntity } from './refresh-token/refresh-token.entity';
import { RefreshTokenService } from './refresh-token/refresh-token.service';
import { LoginAttemptService } from './login-attempt/login-attempt.service';
import { BlacklistModule } from './black-list/black-list.module';
import { PasswordService } from './password/password.service';
import { UserModule } from 'src/user/user.module';
import { UserEntity } from 'src/user/entities/user.entity';
import { UserService } from 'src/user/user.service';
import { UserInstanceModule } from 'src/user-instance/user-instance.module';
import { UserInstanceEntity } from 'src/user-instance/entities/user-instance.entity';
import { UserInstanceService } from 'src/user-instance/user-instance.service';
import { ResetPasswordService } from './reset-password/reset-password.service';
import { AwsSenderModule } from 'src/infra/aws-ses/sender/sender.module';
import { ResetPasswordController } from './reset-password/reset-password.controller';
import { ResetPasswordEntity } from './reset-password/reset-password.entity';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([
      UserEntity,
      RefreshTokenEntity,
      UserInstanceEntity,
      ResetPasswordEntity,
    ]),
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
    PassportModule,
    UserModule,
    UserInstanceModule,
    BlacklistModule,
    AwsSenderModule,
  ],
  providers: [
    AuthService,
    JwtStrategy,
    RefreshTokenService,
    LoginAttemptService,
    PasswordService,
    UserService,
    UserInstanceService,
    ResetPasswordService,
  ],
  controllers: [AuthController, ResetPasswordController],
  exports: [AuthService],
})
export class AuthModule {}
