import {
  Body,
  Controller,
  Delete,
  Get,
  Post,
  Query,
  UseFilters,
  UseGuards,
} from '@nestjs/common';
import { CheckIdentityDto } from './dto/check-identity.dto';
import { AwsSesService } from './aws-ses.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { CreateDomainIdentityDto } from './dto/create-domain-identity.dto';
import { CreateEmailIdentityDto } from './dto/create-email-identity.dto';
import { ListIdentitiesDto } from './dto/list-identidies.dto';
import { SesExceptionFilter } from './filter/ses-exception.filter';
import { RootGuard } from 'src/auth/guards/root.guard';

@UseGuards(JwtGuard)
@UseFilters(SesExceptionFilter)
@Controller('infra/aws-ses')
export class AwsSesController {
  constructor(private readonly sesService: AwsSesService) {}

  @Post('new/domain')
  async createDomainIdentity(@Body() dto: CreateDomainIdentityDto) {
    const accountExist = await this.sesService.checkAccountSESExist(dto.domain);
    if (accountExist) {
      return await this.sesService.checkIdentityStatus({
        identity: dto.domain,
      });
    }
    const response = await this.sesService.createDomainIdentity(dto);
    await this.sesService.createAccountSES(dto.domain);
    return response;
  }

  @Post('new/email')
  async createEmailIdentity(@Body() dto: CreateEmailIdentityDto) {
    const accountExist = await this.sesService.checkAccountSESExist(
      dto.emailAddress,
    );
    if (accountExist) {
      return await this.sesService.checkIdentityStatus({
        identity: dto.emailAddress,
      });
    }
    const response = await this.sesService.createEmailIdentity(dto);
    await this.sesService.createAccountSES(dto.emailAddress);
    return response;
  }

  @Get('identities/check')
  async checkIdentityStatus(@Query() dto: CheckIdentityDto) {
    return await this.sesService.checkIdentityStatus(dto);
  }

  @Delete('identities/delete')
  async removeIdentity(@Query() dto: CheckIdentityDto) {
    return await this.sesService.DeleteIdentity(dto);
  }

  @UseGuards(RootGuard)
  @Get('list')
  async listIdentities(@Query() dto: ListIdentitiesDto) {
    return this.sesService.listIdentities(dto);
  }
}
