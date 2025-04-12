import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);
  const port = config.get<number>('APP_PORT') || 3000;

  await app.listen(port);
  console.log(`🚀 Application running on: http://localhost:${port}`);
}

void bootstrap().catch((err) => {
  console.error('Erro ao iniciar a aplicação', err);
  process.exit(1);
});
