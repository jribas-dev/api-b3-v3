import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserModule } from './user/user.module';
import { InstanceModule } from './instance/instance.module';
import { UserInstanceModule } from './user-instance/user-instance.module';
import { AuthModule } from './auth/auth.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { InfraModule } from './infra/infra.module';

@Module({
  imports: [
    // Habilita leitura de variáveis do .env
    ConfigModule.forRoot({
      isGlobal: true, // Disponível em toda a aplicação
    }),

    // Conexão com banco principal (main_db)
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'mysql',
        host: config.get('DB_HOST'),
        port: config.get<number>('DB_PORT'),
        username: config.get('DB_USERNAME'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_DATABASE'),
        autoLoadEntities: true,
        synchronize: true, // cuidado: use false em produção!
      }),
    }),

    UserModule,

    InstanceModule,

    UserInstanceModule,

    AuthModule,

    InfraModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
