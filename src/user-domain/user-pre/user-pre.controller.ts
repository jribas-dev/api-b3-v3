import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { AdminGuard } from 'src/auth/guards/admin.guard';
import { UserPreService } from './user-pre.service';
import { CreateUserPreDto } from './dto/create-user-pre.dto';
import { CheckUserPreDto } from './dto/check-user-pre.dto';
import { ConfirmUserPreDto } from './dto/confirm-user-pre.dto';

@Controller('user-pre')
export class UserPreController {
  constructor(private readonly userPreService: UserPreService) {}

  @UseGuards(JwtGuard, AdminGuard)
  @Post('create')
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() data: CreateUserPreDto) {
    return this.userPreService.create(data);
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
}
