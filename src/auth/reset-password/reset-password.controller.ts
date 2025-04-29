import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
} from '@nestjs/common';
import { ResetPasswordService } from './reset-password.service';

@Controller('reset-password')
export class ResetPasswordController {
  constructor(private readonly resetPasswordService: ResetPasswordService) {}

  @Post()
  @HttpCode(HttpStatus.OK)
  async passwordReset(@Body() body: { email: string }) {
    await this.resetPasswordService.requestPasswordReset(body.email);
  }

  @Get('check')
  @HttpCode(HttpStatus.OK)
  async checkToken(
    @Query('token') token: string,
    @Query('email') email: string,
  ) {
    const tokenChecked = await this.resetPasswordService.checkToken(
      token,
      email,
    );
    if (!tokenChecked) {
      return { isValid: false };
    }
    return {
      isValid: true,
      name: tokenChecked.user.name,
      email: tokenChecked.user.email,
    };
  }

  @Post('update')
  @HttpCode(HttpStatus.OK)
  async updatePassword(
    @Body()
    body: {
      token: string;
      email: string;
      password: string;
    },
  ) {
    const userUpdated = await this.resetPasswordService.updatePassword(
      body.token,
      body.email,
      body.password,
    );
    if (!userUpdated) {
      return { passwordUpdated: false };
    }
    return {
      passwordUpdated: true,
      name: userUpdated.name,
      email: userUpdated.email,
    };
  }
}
