import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { ValidationPipe } from '@nestjs/common';
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import * as path from 'path';

// Carrega o arquivo .env apropriado com base no NODE_ENV
// dotenv.config({
//   path: `.env.${process.env.NODE_ENV || 'development'}`,
// });

const envFileName = `.env.${process.env.NODE_ENV || 'development'}`;
const envFilePath = path.resolve(process.cwd(), envFileName);

// Verifica se o arquivo existe antes de carregar
if (fs.existsSync(envFilePath)) {
  console.log(`Carregando variáveis de ambiente de: ${envFilePath}`);
  const result = dotenv.config({ path: envFilePath });

  if (result.error) {
    console.error(`Erro ao carregar ${envFileName}:`, result.error);
    throw new Error(`Falha ao carregar arquivo de ambiente ${envFileName}`);
  } else {
    console.log(`Arquivo ${envFileName} carregado com sucesso.`);
  }
} else {
  console.warn(
    `Arquivo ${envFileName} não encontrado. Usando variáveis de ambiente do sistema.`,
  );
}
for (const key in process.env) {
  console.log(`${key}: ${process.env[key]}`);
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  const port = config.get<number>('APP_PORT') || 3000;
  const appName = config.get<string>('APP_NAME') as string;

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // remove campos que não estão no DTO
      forbidNonWhitelisted: true, // lança erro se campos extras forem enviados
      transform: true, // transforma os payloads nos DTOs
    }),
  );

  await app.listen(port);
  console.log(
    `🚀 Application running on: http://localhost:${port}\n   App Name: ${appName}`,
  );
}

void bootstrap().catch((err) => {
  console.error('Erro ao iniciar a aplicação', err);
  process.exit(1);
});
