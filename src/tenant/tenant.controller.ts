import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { AdminGuard } from 'src/auth/guards/admin.guard';
import { CfgService, CfgValue } from './cfg.service';
import { EmpService } from './emp.service';
import { UsuService } from './usu.service';
import { UsuListQueryDto } from './dto/usu-list-query.dto';
import { UsuUpdateDto } from './dto/usu-update.dto';

type JwtRequest = { user: { userId: string; dbId: string } };

@Controller('tenant')
@UseGuards(JwtGuard, UserInstanceGuard)
export class TenantController {
  constructor(
    private readonly empService: EmpService,
    private readonly cfgService: CfgService,
    private readonly usuService: UsuService,
  ) {}

  @Get('emitentes')
  async emitentes(@Request() req: JwtRequest) {
    return this.empService.listEmitentes(req.user.dbId, req.user.userId);
  }

  @Get('cfg')
  async cfg(
    @Request() req: { user: { dbId: string } },
    @Query('param') param: string,
  ): Promise<CfgValue> {
    return this.cfgService.get(req.user.dbId, param);
  }

  @Get('usu/backoffice')
  @UseGuards(AdminGuard)
  @HttpCode(HttpStatus.OK)
  async listUsuBackoffice(
    @Request() req: JwtRequest,
    @Query() query: UsuListQueryDto,
  ) {
    const { dbId, userId } = req.user;
    return this.usuService.listBackoffice(dbId, userId, query.idemp);
  }

  @Patch('usu/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async updateUsu(
    @Request() req: JwtRequest,
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UsuUpdateDto,
  ): Promise<void> {
    const { dbId, userId } = req.user;
    await this.usuService.update(dbId, userId, id, body);
  }
}
