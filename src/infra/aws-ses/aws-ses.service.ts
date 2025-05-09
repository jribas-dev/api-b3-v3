// ses/ses.service.ts
import {
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import {
  CreateEmailIdentityCommand,
  DeleteEmailIdentityCommand,
  GetEmailIdentityCommand,
  ListEmailIdentitiesCommand,
  SESv2Client,
} from '@aws-sdk/client-sesv2';
import { CreateDomainIdentityDto } from './dto/create-domain-identity.dto';
import { CreateEmailIdentityDto } from './dto/create-email-identity.dto';
import { CheckIdentityDto } from './dto/check-identity.dto';
import { ListIdentitiesDto } from './dto/list-identidies.dto';
import { SES_CLIENT } from './factories/ses-client.factory';
import { InjectRepository } from '@nestjs/typeorm';
import { AccountSESEntity } from './entities/account-ses.entity';
import { Repository } from 'typeorm';

@Injectable()
export class AwsSesService {
  constructor(
    @Inject(SES_CLIENT) private readonly sesClient: SESv2Client,
    @InjectRepository(AccountSESEntity)
    private readonly accountSESRepo: Repository<AccountSESEntity>,
  ) {}

  async createDomainIdentity(dto: CreateDomainIdentityDto) {
    const command = new CreateEmailIdentityCommand({
      EmailIdentity: dto.domain,
    });

    const response = await this.sesClient.send(command);
    return {
      identity: dto.domain,
      identityType: 'DOMAIN',
      verificationStatus: 'PENDING',
      dnsRecords: response.DkimAttributes?.Tokens?.map((token) => ({
        token: `CNAME ${token}._domainkey.${dto.domain}  => Target: ${token}.dkim.amazonses.com`,
      })),
    };
    // dkimAttributes->Tokens (Sample DNS records to add)
    // token1._domainkey.exemplo.com.  CNAME  token1.dkim.amazonses.com
  }

  async createEmailIdentity(dto: CreateEmailIdentityDto) {
    const command = new CreateEmailIdentityCommand({
      EmailIdentity: dto.emailAddress,
    });

    await this.sesClient.send(command);
    return {
      identity: dto.emailAddress,
      identityType: 'EMAIL',
      verificationStatus: 'PENDING',
    };
  }

  async DeleteIdentity(dto: CheckIdentityDto) {
    const command = new DeleteEmailIdentityCommand({
      EmailIdentity: dto.identity,
    });
    await this.sesClient.send(command);
    const accountSES = await this.accountSESRepo.findOneBy({
      identity: dto.identity,
    });
    if (accountSES) {
      await this.accountSESRepo.remove(accountSES);
    }
    return {
      identity: dto.identity,
      message: 'Identity deleted successfully',
    };
  }

  async checkIdentityStatus(dto: CheckIdentityDto) {
    const command = new GetEmailIdentityCommand({
      EmailIdentity: dto.identity,
    });

    const response = await this.sesClient.send(command);
    await this.syncAccountSES(
      dto.identity,
      response.VerificationStatus === 'SUCCESS' ? true : false,
    );

    let dnsRecords: string[] | undefined = undefined;
    if (this.determineIdentityType(dto.identity) === 'DOMAIN') {
      dnsRecords = response.DkimAttributes?.Tokens?.map(
        (token, i) =>
          `${i + 1}) CNAME  ${token}._domainkey.${dto.identity}  TARGET  ${token}.dkim.amazonses.com`,
      );
    }

    return {
      identity: dto.identity,
      verificationStatus: response.VerificationStatus,
      identityType: this.determineIdentityType(dto.identity),
      dnsRecords: dnsRecords,
      lastChecked: new Date().toISOString(),
    };
  }

  async syncAccountSES(identity: string, checked: boolean) {
    const accountSES = await this.accountSESRepo.findOneBy({
      identity: identity,
    });
    if (accountSES) {
      accountSES.checked = checked;
      await this.accountSESRepo.save(accountSES);
    } else {
      const newAccountSES = this.accountSESRepo.create({
        identity: identity,
        checked: checked,
      });
      await this.accountSESRepo.save(newAccountSES);
    }
  }

  async createAccountSES(identity: string) {
    const accountSES = this.accountSESRepo.create({
      identity: identity,
      checked: false,
    });
    await this.accountSESRepo.save(accountSES);
  }

  async checkAccountSESExist(identity: string): Promise<boolean> {
    const accountSES = await this.accountSESRepo.findOneBy({ identity });
    if (accountSES) {
      return true;
    }
    return false;
  }

  async listIdentities(dto: ListIdentitiesDto) {
    const command = new ListEmailIdentitiesCommand({
      PageSize: dto.pageSize,
      NextToken: dto.nextToken,
    });

    const response = await this.sesClient.send(command);
    if (!response.EmailIdentities || response.EmailIdentities.length === 0) {
      return {
        identities: [],
        nextToken: null,
      };
    }
    return {
      identities: response.EmailIdentities.map((identity) => ({
        name: identity.IdentityName,
        type: identity.IdentityType,
        status: identity.VerificationStatus,
        sendingEnabled: identity.SendingEnabled,
        lastChecked: new Date().toISOString(),
      })),
      nextToken: response.NextToken,
    };
  }

  private determineIdentityType(identity: string): 'DOMAIN' | 'EMAIL' {
    return identity.includes('@') ? 'EMAIL' : 'DOMAIN';
  }

  // Método genérico para tratamento de erros não cobertos pelo filtro
  private handleGenericError(error: Error) {
    throw new InternalServerErrorException({
      code: 'INTERNAL_SERVER_ERROR',
      message: 'Erro não tratado no serviço SES',
      details: error.message,
    });
  }
}
