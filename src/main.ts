import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  const port = config.get<number>('APP_PORT') || 3000;

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // remove campos que não estão no DTO
      forbidNonWhitelisted: true, // lança erro se campos extras forem enviados
      transform: true, // transforma os payloads nos DTOs
    }),
  );

  await app.listen(port);
  console.log(`🚀 Application running on: http://localhost:${port}`);
}

void bootstrap().catch((err) => {
  console.error('Erro ao iniciar a aplicação', err);
  process.exit(1);
});
