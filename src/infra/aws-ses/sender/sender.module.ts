import { Module } from '@nestjs/common';
import { AwsSenderService } from './sender.service';
import { TemplateFactory } from './factories/template-factory.service';
import { WelcomeHandler } from './handlers/welcome.handler';
import { PasswordResetHandler } from './handlers/password-reset.handler';
import { SesClientFactory } from '../factories/ses-client.factory';
import { NewUserCallHandler } from './handlers/newuser-call.handler';

@Module({
  providers: [
    AwsSenderService,
    TemplateFactory,
    WelcomeHandler,
    PasswordResetHandler,
    NewUserCallHandler,
    SesClientFactory,
  ],
  exports: [AwsSenderService],
})
export class AwsSenderModule {}
