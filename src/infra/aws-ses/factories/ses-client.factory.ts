import { SESv2Client } from '@aws-sdk/client-sesv2';
import { ConfigService } from '@nestjs/config';

export const SES_CLIENT = 'SES_CLIENT';

export const SesClientFactory = {
  provide: SES_CLIENT,
  useFactory: (configService: ConfigService): SESv2Client => {
    const region = configService.get<string>('AWS_REGION') as string;
    const aKeyId = configService.get<string>('AWS_ACCESS_KEY_ID') as string;
    const sKeyId = configService.get<string>('AWS_SECRET_ACCESS_KEY') as string;

    return new SESv2Client({
      region: region,
      credentials: {
        accessKeyId: aKeyId,
        secretAccessKey: sKeyId,
      },
    });
  },
  inject: [ConfigService],
};
