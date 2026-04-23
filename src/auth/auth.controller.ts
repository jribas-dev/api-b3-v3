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
import { LoginDto } from './dto/login.dto';
import { SelectInstanceDto } from './dto/select-instance.dto';
import { Throttle } from '@nestjs/throttler';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly loginAttemptService: LoginAttemptService,
  ) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Req() req: Request, @Body() loginDto: LoginDto) {
    const clientFingerprint = this.loginAttemptService.getIdentifier(
      req,
      loginDto.email,
    );
    await this.loginAttemptService.shouldBlock(clientFingerprint);

    const validUser = await this.authService.validate(
      loginDto.email,
      loginDto.password,
      req,
    );

    const tokenResponse = await this.authService.login(validUser);
    return { isActive: validUser.isActive, ...tokenResponse };
  }

  @Post('instance')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60000, limit: 10 } })
  @UseGuards(JwtGuard)
  async selectInstance(
    @Req() req: Request & { user: { isRoot: boolean; userId: string } },
    @Body() inputDto: SelectInstanceDto,
  ) {
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
