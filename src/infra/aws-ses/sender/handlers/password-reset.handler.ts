import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import handlebars from 'handlebars';
import { TemplateHandler } from '../interfaces/template-handler.interface';

interface PasswordResetContext {
  name: string;
  resetLink: string;
}

@Injectable()
export class PasswordResetHandler
  implements TemplateHandler<PasswordResetContext>
{
  buildHtml(context: PasswordResetContext): string {
    const filePath = path.join(__dirname, '../layouts/password-reset.hbs');
    const source = fs.readFileSync(filePath, 'utf8');
    const template = handlebars.compile<PasswordResetContext>(source);
    return template(context);
  }
}
