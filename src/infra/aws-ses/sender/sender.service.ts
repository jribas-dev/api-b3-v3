import {
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { SES_CLIENT } from '../factories/ses-client.factory';
import { SendEmailCommand, SESv2Client } from '@aws-sdk/client-sesv2';
import { ConfigService } from '@nestjs/config';
import { TemplateFactory } from './factories/template-factory.service';
import { TemplateType } from './enums/template-type.enum';

@Injectable()
export class AwsSenderService {
  private readonly fromAddress: string;
  constructor(
    @Inject(SES_CLIENT) private readonly sesClient: SESv2Client,
    private readonly configService: ConfigService,
    private readonly templateFactory: TemplateFactory,
  ) {
    this.fromAddress = this.configService.get<string>(
      'SES_FROM_EMAIL',
    ) as string;
  }

  async sendTemplateEmail<TContext>(
    to: string,
    subject: string,
    templateType: TemplateType,
    context: TContext,
  ): Promise<void> {
    const handler = this.templateFactory.getHandler<TContext>(templateType);
    const html = handler.buildHtml(context);
    await this.sendEmail(to, subject, html);
  }

  async sendEmail(recipient: string, subject: string, htmlBody: string) {
    try {
      const fromAddress = this.fromAddress || 'passport@3b3.com.br';
      const command = new SendEmailCommand({
        FromEmailAddress: fromAddress,
        Destination: { ToAddresses: [recipient] },
        Content: {
          Simple: {
            Subject: { Data: subject },
            Body: { Html: { Data: htmlBody } },
          },
        },
      });

      const response = await this.sesClient.send(command);
      return {
        statusCode: 200,
        messageId: response.MessageId,
        recipient: recipient,
        subject: subject,
      };
    } catch (error) {
      this.handleGenericError(error as Error);
    }
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
