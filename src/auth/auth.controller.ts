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
import { UserInstanceGuard } from './guards/user-instance.guard';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly loginAttemptService: LoginAttemptService,
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
  // @UseGuards(JwtGuard, UserInstanceGuard)
  @HttpCode(HttpStatus.OK)
  async refresh(@Body() body: { refreshToken: string }) {
    return this.authService.refresh(body.refreshToken);
  }

  @Post('logout')
  @UseGuards(JwtGuard, UserInstanceGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@Req() req: Request): Promise<{ message: string }> {
    if (await this.authService.logout(req)) {
      return { message: 'Logout realizado com sucesso' };
    } else {
      throw new BadRequestException('Logout falhou');
    }
  }
}
