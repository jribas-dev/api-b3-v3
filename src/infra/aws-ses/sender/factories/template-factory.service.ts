import { Injectable } from '@nestjs/common';
import { TemplateType } from '../enums/template-type.enum';
import { WelcomeHandler } from '../handlers/welcome.handler';
import { PasswordResetHandler } from '../handlers/password-reset.handler';
import { TemplateHandler } from '../interfaces/template-handler.interface';
import { NewUserCallHandler } from '../handlers/newuser-call.handler';

@Injectable()
export class TemplateFactory {
  constructor(
    private readonly welcomeHandler: WelcomeHandler,
    private readonly passwordResetHandler: PasswordResetHandler,
    private readonly newUserCallHandler: NewUserCallHandler,
  ) {}

  getHandler<TContext>(templateType: TemplateType): TemplateHandler<TContext> {
    switch (templateType) {
      case TemplateType.WELCOME:
        return this.welcomeHandler as TemplateHandler<TContext>;
      case TemplateType.PASSWORD_RESET:
        return this.passwordResetHandler as TemplateHandler<TContext>;
      case TemplateType.NEWUSER_CALL:
        return this.newUserCallHandler as TemplateHandler<TContext>;
      default:
        throw new Error(`Unknown template type: ${templateType}`);
    }
  }
}
