import { Injectable } from '@nestjs/common';
import { TemplateType } from '../enums/template-type.enum';
import { WelcomeHandler } from '../handlers/welcome.handler';
import { PasswordResetHandler } from '../handlers/password-reset.handler';
import { TemplateHandler } from '../interfaces/template-handler.interface';

@Injectable()
export class TemplateFactory {
  constructor(
    private readonly welcomeHandler: WelcomeHandler,
    private readonly passwordResetHandler: PasswordResetHandler,
  ) {}

  getHandler<TContext>(templateType: TemplateType): TemplateHandler<TContext> {
    switch (templateType) {
      case TemplateType.WELCOME:
        return this.welcomeHandler as TemplateHandler<TContext>;
      case TemplateType.PASSWORD_RESET:
        return this.passwordResetHandler as TemplateHandler<TContext>;
      default:
        throw new Error(`Unknown template type: ${templateType}`);
    }
  }
}
