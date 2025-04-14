import { Injectable, InternalServerErrorException } from '@nestjs/common';
import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import { PutObjectDto } from './dto/put-object.dto';
import { DeleteObjectDto } from './dto/delete-object.dto';
import { ConfigService } from '@nestjs/config';
import { createReadStream } from 'fs';
import { join } from 'path';

@Injectable()
export class AwsS3Service {
  private readonly s3: S3Client;
  private readonly defaultBucket: string | undefined;
  private readonly uploadPath: string;

  constructor(private readonly configService: ConfigService) {
    const region = this.configService.get<string>('AWS_REGION') as string;

    const aKeyId = this.configService.get<string>(
      'AWS_ACCESS_KEY_ID',
    ) as string;

    const sKeyId = this.configService.get<string>(
      'AWS_SECRET_ACCESS_KEY',
    ) as string;

    this.defaultBucket = this.configService.get<string>(
      'AWS_S3_BUCKET_NAME',
    ) as string;

    this.uploadPath = this.configService.get<string>('UPLOAD_PATH') as string;

    this.s3 = new S3Client({
      region: region,
      credentials: {
        accessKeyId: aKeyId,
        secretAccessKey: sKeyId,
      },
    });
  }

  async uploadFromDisk(file: Express.Multer.File, dto: PutObjectDto) {
    const targetBucket = dto.bucket || this.defaultBucket;
    const filePath = join(this.uploadPath, dto.folder, file.filename);

    try {
      const fileStream = createReadStream(filePath);

      const command = new PutObjectCommand({
        Bucket: targetBucket,
        Key: dto.key,
        Body: fileStream,
        ContentType: dto.contentType,
      });

      const response = await this.s3.send(command);

      return {
        success: true,
        objectUrl: `https://${targetBucket}.s3.amazonaws.com/${dto.key}`,
        ETag: response.ETag,
      };
    } catch (error) {
      if (error instanceof Error) {
        throw new InternalServerErrorException({
          message: 'Erro ao enviar para o S3',
          error: error.message,
        });
      } else {
        throw new InternalServerErrorException({
          message: 'Erro ao enviar para o S3',
          error: String(error),
        });
      }
    }
  }

  async deleteObject(dto: DeleteObjectDto) {
    const targetBucket = dto.bucket || this.defaultBucket;

    try {
      const command = new DeleteObjectCommand({
        Bucket: targetBucket,
        Key: dto.key,
      });

      await this.s3.send(command);

      return {
        success: true,
        message: 'Arquivo deletado com sucesso',
        deletedKey: dto.key,
      };
    } catch (error) {
      if (error instanceof Error) {
        throw new InternalServerErrorException({
          message: 'Erro ao deletar arquivo no S3',
          error: error.message,
        });
      } else {
        throw new InternalServerErrorException({
          message: 'Erro ao deletar arquivo no S3',
          error: String(error),
        });
      }
    }
  }
}
