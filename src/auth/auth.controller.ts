import {
  Controller,
  Post,
  Body,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginAttemptService } from './login-attempt/login-attempt.service';
import { Request } from 'express';
import { JwtGuard } from './guards/jwt.guard';
import { BlacklistService } from './black-list/black-list.service';
import { JwtService } from '@nestjs/jwt';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly loginAttemptService: LoginAttemptService,
    private readonly jwtService: JwtService,
    private readonly blacklistService: BlacklistService,
  ) {}

  @Post('login')
  async login(
    @Req() req: Request,
    @Body() body: { email: string; password: string },
  ): Promise<any> {
    const ip = req.ip || '255.255.255.255';
    const userAgent = req.headers['user-agent'] || 'unknown';

    if (this.loginAttemptService.isBlocked(ip, userAgent)) {
      throw new UnauthorizedException(
        '🔒 Muitas tentativas mal sucedidas. Tente novamente em 1 hora.',
      );
    }

    const { email, password } = body;
    const result = await this.authService.validateUser(email, password);

    if (!result) {
      const warning = this.loginAttemptService.registerFailedAttempt(
        ip,
        userAgent,
      );
      throw new UnauthorizedException(
        `Credenciais inválidas.${warning ? ' ' + warning : ''}`,
      );
    }

    this.loginAttemptService.clearAttempts(ip, userAgent); // reset em caso de sucesso

    return this.authService.login(result);
  }

  @Post('refresh')
  async refresh(@Body() body: { refreshToken: string }) {
    return this.authService.refresh(body.refreshToken);
  }

  @Post('logout')
  @UseGuards(JwtGuard)
  async logout(@Req() req: Request): Promise<{ message: string }> {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return { message: 'Token de autenticação não encontrado.' };
    }

    const token = authHeader.replace('Bearer ', '').trim();
    const decoded: { exp?: number } | null = this.jwtService.decode(token);

    if (decoded?.exp) {
      const expiresAt = new Date(decoded.exp * 1000);
      await this.blacklistService.addToken(token, expiresAt);
    }

    return { message: 'Logout realizado com sucesso.' };
  }
}
