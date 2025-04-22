// import { ConfigService } from '@nestjs/config';
// import { MulterModuleOptions } from '@nestjs/platform-express';
// import { diskStorage } from 'multer';
// import * as fs from 'fs';
// import { extname, join } from 'path';
// import { Injectable } from '@nestjs/common';
// import { Request } from 'express';

// @Injectable()
// export class MulterConfigService {
//   constructor(private readonly configService: ConfigService) {}

//   createMulterOptions(): MulterModuleOptions {
//     console.log('MulterConfigService.createMulterOptions called');
//     const basePath = this.configService.get<string>('UPLOAD_PATH') as string;
//     return {
//       storage: diskStorage({
//         destination: (req: Request, file, cb) => {
//           const folder = req.query.folder || 'default-folder';
//           if (folder) {
//             cb(new Error('Folder is required'), '');
//             return;
//           }
//           const folderPath = join(basePath, folder);
//           if (!fs.existsSync(folderPath)) {
//             fs.mkdirSync(folderPath, { recursive: true });
//           }
//           cb(null, folderPath);
//         },
//         filename: (req, file, cb) => {
//           const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
//           const ext = extname(file.originalname);
//           cb(null, `${uniqueName}${ext}`);
//         },
//       }),
//     };
//   }
// }

// import { ConfigService } from '@nestjs/config';
// import { Injectable } from '@nestjs/common';
// import { diskStorage, Options } from 'multer';
// import { extname, join } from 'path';
// import * as fs from 'fs';
// import { PutObjectDto } from '../dto/put-object.dto';

// @Injectable()
// export class MulterOptionsFactory {
//   constructor(private readonly configService: ConfigService) {}

//   createMulterOptions(): Options {
//     return {
//       storage: diskStorage({
//         destination: (req, file, cb) => {
//           const body: PutObjectDto = req.body as PutObjectDto;
//           const basePath = this.configService.get<string>(
//             'UPLOAD_PATH',
//           ) as string;
//           const folderPath = join(basePath, body.folder);

//           if (!fs.existsSync(folderPath)) {
//             fs.mkdirSync(folderPath, { recursive: true });
//           }

//           cb(null, folderPath);
//         },
//         filename: (req, file, cb) => {
//           const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
//           const ext = extname(file.originalname);
//           cb(null, `${uniqueName}${ext}`);
//         },
//       }),
//     };
//   }
// }
