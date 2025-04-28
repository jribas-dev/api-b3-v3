import {
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
  S3ServiceException,
  PutObjectCommandOutput,
} from '@aws-sdk/client-s3';
import { ConfigService } from '@nestjs/config';
import { join } from 'path';
import { promises as fsPromises } from 'fs';
import { S3_CLIENT } from './factories/s3-client.factory';
import { Readable } from 'stream';

@Injectable()
export class AwsS3Service {
  private readonly region: string;
  private readonly defaultBucket: string | undefined;
  private readonly uploadPath: string;
  private readonly staticUrl: string;

  constructor(
    @Inject(S3_CLIENT) private readonly s3: S3Client,
    private readonly configService: ConfigService,
  ) {
    this.region =
      (this.configService.get<string>('AWS_REGION') as string) || 'us-east-1';
    this.defaultBucket = this.configService.get<string>(
      'S3_BUCKET_NAME',
    ) as string;
    this.uploadPath = this.configService.get<string>('UPLOAD_PATH') as string;
    this.staticUrl = this.configService.get<string>('STATIC_URL') as string;
  }

  async uploadLocal(
    file: Express.Multer.File,
    folder: string,
    fileName: string,
  ) {
    const targetDir = join(this.uploadPath, folder);
    const fullPath = join(targetDir, fileName);

    try {
      await fsPromises.mkdir(targetDir, { recursive: true });
      await fsPromises.writeFile(fullPath, file.buffer);
      return {
        success: true,
        message: 'Arquivo enviado para servidor da aplicação',
        filePath: fullPath,
        objectUrl: `${this.staticUrl}${folder}/${fileName}`,
      };
    } catch (error) {
      throw new InternalServerErrorException({
        message: `Erro ao salvar arquivo no disco: ${(error as Error).message}`,
      });
    }
  }

  async deleteLocal(folder: string, fileName: string) {
    const fullPath = join(this.uploadPath, folder, fileName);
    try {
      await fsPromises.unlink(fullPath);
      return {
        success: true,
        message: 'Arquivo deletado com sucesso',
      };
    } catch (error) {
      throw new InternalServerErrorException({
        message: `Erro ao deletar arquivo no disco: ${(error as Error).message}`,
      });
    }
  }

  async uploadAwsS3(
    file: Express.Multer.File,
    fullKey: string,
    bucket?: string,
  ) {
    let response: PutObjectCommandOutput;
    const targetBucket = bucket || this.defaultBucket;
    const stream = Readable.from(file.buffer);
    const command = new PutObjectCommand({
      Bucket: targetBucket,
      Key: fullKey,
      Body: stream,
      ContentType: file.mimetype,
      ContentLength: file.size,
      ACL: 'public-read',
    });
    try {
      response = await this.s3.send(command);
      return {
        success: true,
        message: 'Arquivo enviado com sucesso',
        objectUrl: `https://${targetBucket}.s3.${this.region}.amazonaws.com/${fullKey}`,
        ETag: response.ETag,
      };
    } catch (error) {
      if (error instanceof S3ServiceException) {
        const statusCode = error.$metadata?.httpStatusCode || 500;
        const errorMessage = `Erro no AWS S3 [${statusCode}]: ${error.name} - ${error.message}`;
        throw new InternalServerErrorException(errorMessage);
      }
      throw new Error(`Erro desconhecido no upload: ${error as string}`);
    }
  }

  async deleteAwsS3(fullKey: string, bucket?: string) {
    const targetBucket = bucket || this.defaultBucket;
    const command = new DeleteObjectCommand({
      Bucket: targetBucket,
      Key: fullKey,
    });
    try {
      await this.s3.send(command);
      return {
        success: true,
        message: 'Arquivo deletado com sucesso',
        deletedKey: fullKey,
      };
    } catch (error) {
      if (error instanceof S3ServiceException) {
        const statusCode = error.$metadata?.httpStatusCode;
        const errorMessage = `Erro no AWS S3 [${statusCode}]: ${error.name} - ${error.message}`;
        throw new InternalServerErrorException(errorMessage);
      }
      throw new Error(`Erro desconhecido no delete: ${error as string}`);
    }
  }
}
