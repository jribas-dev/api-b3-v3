import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { AdminGuard } from 'src/auth/guards/admin.guard';
import { UserPreService } from './user-pre.service';
import { CreateUserPreDto } from './dto/create-user-pre.dto';
import { CheckUserPreDto } from './dto/check-user-pre.dto';
import { ConfirmUserPreDto } from './dto/confirm-user-pre.dto';
import { InviteActionDto } from './dto/invite-action.dto';

@Controller('user-pre')
export class UserPreController {
  constructor(private readonly userPreService: UserPreService) {}

  @UseGuards(JwtGuard, AdminGuard)
  @Post('create')
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() data: CreateUserPreDto,
    @Request() req: { user: { userId: string } },
  ) {
    return this.userPreService.create(data, req.user.userId);
  }

  @Get('check')
  @HttpCode(HttpStatus.OK)
  async check(@Query() data: CheckUserPreDto) {
    return this.userPreService.checkUserPre(data);
  }

  @Post('confirm')
  @HttpCode(HttpStatus.CREATED)
  async confirm(@Body() data: ConfirmUserPreDto) {
    return this.userPreService.confirmUser(data.user, data.check);
  }

  @UseGuards(JwtGuard, AdminGuard)
  @Get('my-invites')
  @HttpCode(HttpStatus.OK)
  async myInvites(@Request() req: { user: { userId: string } }) {
    return this.userPreService.findMyInvites(req.user.userId);
  }

  @UseGuards(JwtGuard, AdminGuard)
  @Post('resend')
  @HttpCode(HttpStatus.NO_CONTENT)
  async resend(@Body() data: InviteActionDto) {
    return this.userPreService.resendInvite(data.email);
  }

  @UseGuards(JwtGuard, AdminGuard)
  @Post('regenerate')
  @HttpCode(HttpStatus.NO_CONTENT)
  async regenerate(@Body() data: InviteActionDto) {
    return this.userPreService.regenerateToken(data.email);
  }
}
