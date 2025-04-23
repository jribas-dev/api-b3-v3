import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { CheckIdentityDto } from './dto/check-identity.dto';
import { AwsSesService } from './aws-ses.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { CreateDomainIdentityDto } from './dto/create-domain-identity.dto';
import { CreateEmailIdentityDto } from './dto/create-email-identity.dto';
import { ListIdentitiesDto } from './dto/list-identidies.dto';

@UseGuards(JwtGuard)
@Controller('infra/aws-ses')
export class AwsSesController {
  constructor(private readonly sesService: AwsSesService) {}

  @Post('new/domain')
  async createDomainIdentity(@Body() dto: CreateDomainIdentityDto) {
    return await this.sesService.createDomainIdentity(dto);
  }

  @Post('new/email')
  async createEmailIdentity(@Body() dto: CreateEmailIdentityDto) {
    return await this.sesService.createEmailIdentity(dto);
  }

  @Get('identities/check')
  async checkIdentityStatus(@Query() dto: CheckIdentityDto) {
    return await this.sesService.checkIdentityStatus(dto);
  }

  @Get('list')
  async listIdentities(@Query() dto: ListIdentitiesDto) {
    return this.sesService.listIdentities(dto);
  }
}
