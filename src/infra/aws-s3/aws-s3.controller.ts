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
import { PutObjectDto } from './dto/put-object.dto';
import { DeleteObjectDto } from './dto/delete-object.dto';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { FileInterceptor } from '@nestjs/platform-express';

@UseGuards(JwtGuard)
@Controller('infra/aws-s3')
export class AwsS3Controller {
  constructor(private readonly awsS3Service: AwsS3Service) {}

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
    @Body() dto: PutObjectDto,
  ) {
    if (!file) {
      throw new BadRequestException('File in a form-data is required');
    }
    if (!dto.folder) {
      throw new BadRequestException('folder is required');
    }
    const localResult = await this.awsS3Service.uploadFile(file, dto.folder);
    return localResult;
  }

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
    @Body() dto: PutObjectDto,
  ) {
    if (!file) {
      throw new BadRequestException('File in a form-data is required');
    }
    if (!dto.folder) {
      throw new BadRequestException('folder is required');
    }
    if (!dto.fullKey) {
      throw new BadRequestException('fullKey is required');
    }
    const uploadResult = await this.awsS3Service.uploadAwsS3(
      file,
      dto.fullKey,
      dto.bucket,
    );
    return uploadResult;
  }

  @Delete('deletefile')
  async deleteFile(@Body() dto: DeleteObjectDto) {
    const { fullKey, bucket } = dto;
    if (!fullKey) {
      throw new BadRequestException('fullKey is required');
    }
    return await this.awsS3Service.deleteObject(fullKey, bucket);
  }
}
