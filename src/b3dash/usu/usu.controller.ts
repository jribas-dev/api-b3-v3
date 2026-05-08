import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { AdminGuard } from 'src/auth/guards/admin.guard';
import { UsuService } from './usu.service';
import { UsuListQueryDto } from './dto/usu-list-query.dto';

type JwtRequest = { user: { userId: string; dbId: string } };

@Controller('b3dash/usu')
@UseGuards(JwtGuard, UserInstanceGuard, AdminGuard)
export class UsuController {
  constructor(private readonly usuService: UsuService) {}

  @Get('list/backoffice')
  @HttpCode(HttpStatus.OK)
  async listBackoffice(
    @Request() req: JwtRequest,
    @Query() query: UsuListQueryDto,
  ) {
    const { dbId, userId } = req.user;
    return this.usuService.listBackoffice(dbId, userId, query.idemp);
  }
}
