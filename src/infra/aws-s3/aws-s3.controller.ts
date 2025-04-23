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

  @Post('uploadfile')
  @UseInterceptors(FileInterceptor('file'))
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
    if (!dto.key) {
      throw new BadRequestException('key is required');
    }
    await this.awsS3Service.uploadFile(file, dto.folder);
    const uploadResult = await this.awsS3Service.uploadAwsS3(
      file,
      dto.key,
      dto.bucket,
    );
    return uploadResult;
  }

  @Delete('deletefile')
  async deleteFile(@Body() dto: DeleteObjectDto) {
    const { key, bucket } = dto;
    if (!key) {
      throw new BadRequestException('key is required');
    }
    return await this.awsS3Service.deleteObject(key, bucket);
  }
}
