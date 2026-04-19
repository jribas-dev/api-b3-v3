import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import { EmpService } from './emp.service';

@Controller('tenant')
@UseGuards(JwtGuard, UserInstanceGuard)
export class TenantController {
  constructor(private readonly empService: EmpService) {}

  @Get('emitentes')
  async emitentes(@Request() req: { user: { userId: string; dbId: string } }) {
    return this.empService.listEmitentes(req.user.dbId, req.user.userId);
  }
}
