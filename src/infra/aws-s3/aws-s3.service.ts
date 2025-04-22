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
import { DeleteObjectDto } from './dto/delete-object.dto';
import { ConfigService } from '@nestjs/config';
import { createReadStream } from 'fs';
import { join } from 'path';
import { promises as fsPromises } from 'fs';
import { S3_CLIENT } from './factories/s3-client.factory';

@Injectable()
export class AwsS3Service {
  private readonly region: string;
  private readonly defaultBucket: string | undefined;
  private readonly uploadPath: string;

  constructor(
    @Inject(S3_CLIENT) private readonly s3: S3Client,
    private readonly configService: ConfigService,
  ) {
    this.region =
      (this.configService.get<string>('AWS_REGION') as string) || 'us-east-1';
    this.defaultBucket = this.configService.get<string>(
      'AWS_S3_BUCKET_NAME',
    ) as string;
    this.uploadPath = this.configService.get<string>('UPLOAD_PATH') as string;
  }

  async uploadFile(file: Express.Multer.File, folder: string): Promise<string> {
    console.log('uploadFile', file, folder);
    const targetDir = join(this.uploadPath, folder);
    const fullPath = join(targetDir, file.originalname);

    try {
      await fsPromises.mkdir(targetDir, { recursive: true });
      await fsPromises.writeFile(fullPath, file.buffer);
      return fullPath;
    } catch (error) {
      throw new InternalServerErrorException({
        message: `Erro ao salvar arquivo no disco: ${(error as Error).message}`,
      });
    }
  }

  async uploadAwsS3(filePath: string, fileKey: string, bucket?: string) {
    let response: PutObjectCommandOutput;
    const targetBucket = bucket || this.defaultBucket;
    const fileStream = createReadStream(filePath);
    const command = new PutObjectCommand({
      Bucket: targetBucket,
      Key: fileKey,
      Body: fileStream,
      ACL: 'public-read',
    });
    try {
      response = await this.s3.send(command);
    } catch (error) {
      if (error instanceof S3ServiceException) {
        const statusCode = error.$metadata?.httpStatusCode;
        const errorMessage = `Erro no AWS S3 [${statusCode}]: ${error.name} - ${error.message}`;
        throw new Error(errorMessage);
      }
      throw new Error(`Erro desconhecido no upload: ${error as string}`);
    }
    return {
      success: true,
      message: 'Arquivo enviado com sucesso',
      objectUrl: `https://${targetBucket}.s3.${this.region}.amazonaws.com/${fileKey}`,
      ETag: response.ETag,
    };
  }

  async deleteObject(dto: DeleteObjectDto) {
    const targetBucket = dto.bucket || this.defaultBucket;
    const command = new DeleteObjectCommand({
      Bucket: targetBucket,
      Key: dto.key,
    });
    try {
      await this.s3.send(command);
    } catch (error) {
      if (error instanceof S3ServiceException) {
        const statusCode = error.$metadata?.httpStatusCode;
        const errorMessage = `Erro no AWS S3 [${statusCode}]: ${error.name} - ${error.message}`;
        throw new Error(errorMessage);
      }
      throw new Error(`Erro desconhecido no delete: ${error as string}`);
    }
    return {
      success: true,
      message: 'Arquivo deletado com sucesso',
      deletedKey: dto.key,
    };
  }
}
