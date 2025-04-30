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
import { B3vendasModule } from './b3vendas/b3vendas.module';
import { UserPreModule } from './user-pre/user-pre.module';
import { configSchemaValidation } from './config.schema';

@Module({
  imports: [
    // Habilita leitura de variáveis do .env
    ConfigModule.forRoot({
      isGlobal: true, // Disponível em toda a aplicação
      validationSchema: configSchemaValidation,
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

    UserPreModule,

    B3vendasModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
