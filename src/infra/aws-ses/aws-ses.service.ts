// ses/ses.service.ts
import {
  Injectable,
  InternalServerErrorException,
  UseFilters,
} from '@nestjs/common';
import {
  SESv2Client,
  CreateEmailIdentityCommand,
  GetEmailIdentityCommand,
  ListEmailIdentitiesCommand,
} from '@aws-sdk/client-sesv2';
import { CreateDomainIdentityDto } from './dto/create-domain-identity.dto';
import { CreateEmailIdentityDto } from './dto/create-email-identity.dto';
import { SesExceptionFilter } from './filter/ses-exception.filter';
import { CheckIdentityDto } from './dto/check-identity.dto';
import { ListIdentitiesDto } from './dto/list-identidies.dto';

@Injectable()
export class AwsSesService {
  constructor(private readonly sesClient: SESv2Client) {}

  @UseFilters(SesExceptionFilter)
  async createDomainIdentity(dto: CreateDomainIdentityDto) {
    const command = new CreateEmailIdentityCommand({
      EmailIdentity: dto.domain,
    });

    const response = await this.sesClient.send(command);
    return {
      identity: dto.domain,
      verificationStatus: 'PENDING', // Domínios sempre requerem verificação
      dkimAttributes: response.DkimAttributes,
    };
  }

  @UseFilters(SesExceptionFilter)
  async createEmailIdentity(dto: CreateEmailIdentityDto) {
    const command = new CreateEmailIdentityCommand({
      EmailIdentity: dto.emailAddress,
    });

    await this.sesClient.send(command);
    return {
      identity: dto.emailAddress,
      verificationStatus: 'SUCCESS', // E-mails são verificados automaticamente no sandbox
    };
  }

  @UseFilters(SesExceptionFilter)
  async checkIdentityStatus(dto: CheckIdentityDto) {
    const command = new GetEmailIdentityCommand({
      EmailIdentity: dto.identity,
    });

    const response = await this.sesClient.send(command);

    return {
      identity: dto.identity,
      verificationStatus: response.VerificationStatus,
      dkimAttributes: response.DkimAttributes,
      identityType: this.determineIdentityType(dto.identity),
      lastChecked: new Date().toISOString(),
    };
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
