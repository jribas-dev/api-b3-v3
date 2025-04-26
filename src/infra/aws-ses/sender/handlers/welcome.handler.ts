import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import handlebars from 'handlebars';
import { TemplateHandler } from '../interfaces/template-handler.interface';

interface WelcomeContext {
  name: string;
}

@Injectable()
export class WelcomeHandler implements TemplateHandler<WelcomeContext> {
  buildHtml(context: WelcomeContext): string {
    const filePath = path.join(__dirname, '../layouts/welcome.hbs');
    const source = fs.readFileSync(filePath, 'utf8');
    const template = handlebars.compile<WelcomeContext>(source);
    return template(context);
  }
}
