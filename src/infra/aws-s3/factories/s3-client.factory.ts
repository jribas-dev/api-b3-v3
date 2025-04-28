import { S3Client } from '@aws-sdk/client-s3';
import { ConfigService } from '@nestjs/config';

export const S3_CLIENT = 'S3_CLIENT';

export const s3ClientFactory = {
  provide: S3_CLIENT,
  useFactory: (configService: ConfigService): S3Client => {
    const region = configService.get<string>('AWS_REGION') as string;
    const aKeyId = configService.get<string>('AWS_S3_KEY') as string;
    const sKeyId = configService.get<string>('AWS_S3_SECRET') as string;

    return new S3Client({
      region: region,
      credentials: {
        accessKeyId: aKeyId,
        secretAccessKey: sKeyId,
      },
    });
  },
  inject: [ConfigService],
};
