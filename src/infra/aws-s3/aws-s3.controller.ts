import {
  Controller,
  Post,
  Delete,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { AwsS3Service } from './aws-s3.service';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { FileInterceptor } from '@nestjs/platform-express';
import { join } from 'path';
import { ActionsFileObjectDto } from './dtos/actions-file-object.dto';

@UseGuards(JwtGuard)
@Controller('infra/aws-s3')
export class AwsS3Controller {
  constructor(private readonly awsS3Service: AwsS3Service) {}

  /**
   * @warning Todos os arquivos enviados serão PÚBLICOS
   * Não utilize para dados sensíveis
   */
  @Post('uploadfile/local')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 1024 * 1024 * 150, // 150MB
      },
    }),
  )
  async uploadFileLocal(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: ActionsFileObjectDto,
  ) {
    if (!file) {
      throw new BadRequestException('File in a form-data is required');
    }
    if (!dto.folderName) {
      throw new BadRequestException('folder is required');
    }
    const localResult = await this.awsS3Service.uploadLocal(
      file,
      dto.folderName,
      dto.fileName,
    );
    return localResult;
  }

  /**
   * @warning Todos os arquivos enviados serão PÚBLICOS
   * Não utilize para dados sensíveis
   */
  @Post('uploadfile')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 1024 * 1024 * 150, // 150MB
      },
    }),
  )
  async uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: ActionsFileObjectDto,
  ) {
    if (!file) {
      throw new BadRequestException('File in a form-data is required');
    }
    if (!dto.folderName) {
      throw new BadRequestException('folderName is required');
    }
    if (!dto.fileName) {
      throw new BadRequestException('fileName is required');
    }
    const fullKey = join(dto.folderName, dto.fileName).replace(/\\/g, '/');
    const uploadResult = await this.awsS3Service.uploadAwsS3(
      file,
      fullKey,
      dto.bucket,
    );
    return uploadResult;
  }

  @Delete('deletefile/local')
  async deleteFileLocal(@Body() dto: ActionsFileObjectDto) {
    const { folderName, fileName } = dto;
    if (!folderName) {
      throw new BadRequestException('folderName is required');
    }
    if (!fileName) {
      throw new BadRequestException('fileName is required');
    }
    return await this.awsS3Service.deleteLocal(folderName, fileName);
  }

  @Delete('deletefile')
  async deleteFile(@Body() dto: ActionsFileObjectDto) {
    const { folderName, fileName, bucket } = dto;
    if (!folderName) {
      throw new BadRequestException('folderName is required');
    }
    if (!fileName) {
      throw new BadRequestException('fileName is required');
    }
    const fullKey = join(folderName, fileName).replace(/\\/g, '/');
    return await this.awsS3Service.deleteAwsS3(fullKey, bucket);
  }
}
