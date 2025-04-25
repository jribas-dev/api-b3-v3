import {
  Controller,
  Post,
  Body,
  Req,
  HttpCode,
  HttpStatus,
  UseGuards,
  BadRequestException,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginAttemptService } from './login-attempt/login-attempt.service';
import { Request } from 'express';
import { JwtGuard } from './guards/jwt.guard';
import { BlacklistService } from './black-list/black-list.service';
import { JwtService } from '@nestjs/jwt';
import { UserInstanceGuard } from './guards/user-instance.guard';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly loginAttemptService: LoginAttemptService,
    private readonly jwtService: JwtService,
    private readonly blacklistService: BlacklistService,
  ) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(
    @Req() req: Request,
    @Body() loginDto: { email: string; password: string },
  ) {
    const clientFingerprint = this.loginAttemptService.getIdentifier(req);
    await this.loginAttemptService.shouldBlock(clientFingerprint);

    const validUser = await this.authService.validate(
      loginDto.email,
      loginDto.password,
      req,
    );

    if (validUser) {
      const tokenResponse = await this.authService.login(validUser);
      return tokenResponse;
    }
  }

  @Post('instance')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtGuard)
  async selectInstance(
    @Req() req: Request & { user: { isRoot: boolean; userId: string } },
    @Body() inputDto: { dbId: string },
  ) {
    if (!req.user.userId || !inputDto.dbId) {
      throw new BadRequestException(
        'ID do usuário ou ID da instância não fornecidos.',
      );
    }
    const validUser = await this.authService.validateUserInstance(
      req.user.userId,
      inputDto.dbId,
    );
    const tokenResponse = await this.authService.loginInstance(validUser);
    return tokenResponse;
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtGuard)
  @UseGuards(UserInstanceGuard)
  async refresh(@Body() body: { refreshToken: string }) {
    return this.authService.refresh(body.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtGuard)
  @UseGuards(UserInstanceGuard)
  async logout(@Req() req: Request): Promise<{ message: string }> {
    const authHeader = req.headers.authorization as string;
    const token = authHeader.replace('Bearer ', '').trim();
    const decoded: { exp?: number } | null = this.jwtService.decode(token);

    if (decoded?.exp) {
      const expiresAt = new Date(decoded.exp * 1000);
      await this.blacklistService.addToken(token, expiresAt);
    }

    return { message: 'Logout realizado com sucesso.' };
  }
}
