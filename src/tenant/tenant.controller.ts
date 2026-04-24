import { Controller, Get, Query, Request, UseGuards } from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { CfgService, CfgValue } from './cfg.service';
import { EmpService } from './emp.service';

@Controller('tenant')
@UseGuards(JwtGuard, UserInstanceGuard)
export class TenantController {
  constructor(
    private readonly empService: EmpService,
    private readonly cfgService: CfgService,
  ) {}

  @Get('emitentes')
  async emitentes(@Request() req: { user: { userId: string; dbId: string } }) {
    return this.empService.listEmitentes(req.user.dbId, req.user.userId);
  }

  @Get('cfg')
  async cfg(
    @Request() req: { user: { dbId: string } },
    @Query('param') param: string,
  ): Promise<CfgValue> {
    return this.cfgService.get(req.user.dbId, param);
  }
}
