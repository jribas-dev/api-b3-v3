import { S3Client } from '@aws-sdk/client-s3';
import { NodeHttpHandler } from '@smithy/node-http-handler';
import { ConfigService } from '@nestjs/config';

export const S3_CLIENT = 'S3_CLIENT';

export const s3ClientFactory = {
  provide: S3_CLIENT,
  useFactory: (configService: ConfigService): S3Client => {
    const region = configService.get<string>('AWS_REGION') as string;
    const aKeyId = configService.get<string>('AWS_SDK_KEY') as string;
    const sKeyId = configService.get<string>('AWS_SDK_SECRET') as string;

    return new S3Client({
      region: region,
      credentials: {
        accessKeyId: aKeyId,
        secretAccessKey: sKeyId,
      },
      requestHandler: new NodeHttpHandler({ requestTimeout: 10_000 }),
    });
  },
  inject: [ConfigService],
};
