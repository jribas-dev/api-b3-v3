import { Module } from '@nestjs/common';
import { AwsSenderService } from './sender.service';
import { TemplateFactory } from './factories/template-factory.service';
import { WelcomeHandler } from './handlers/welcome.handler';
import { PasswordResetHandler } from './handlers/password-reset.handler';

@Module({
  providers: [
    AwsSenderService,
    TemplateFactory,
    WelcomeHandler,
    PasswordResetHandler,
  ],
  exports: [AwsSenderService],
})
export class AwsSenderModule {}
