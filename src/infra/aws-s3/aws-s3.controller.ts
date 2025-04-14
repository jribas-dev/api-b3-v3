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
    if (!dto.folder) {
      throw new BadRequestException('folder is required');
    }

    return this.awsS3Service.uploadFromDisk(file, dto);
  }

  @Delete('deletefile')
  async deleteFile(@Body() dto: DeleteObjectDto) {
    return this.awsS3Service.deleteObject(dto);
  }
}
