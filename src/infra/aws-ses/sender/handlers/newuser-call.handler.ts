import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import handlebars from 'handlebars';
import { TemplateHandler } from '../interfaces/template-handler.interface';

interface NewUserCallContext {
  name: string;
  newUserLink: string;
}

@Injectable()
export class NewUserCallHandler implements TemplateHandler<NewUserCallContext> {
  buildHtml(context: NewUserCallContext): string {
    const filePath = path.join(__dirname, '../layouts/newuser-call.hbs');
    const source = fs.readFileSync(filePath, 'utf8');
    const template = handlebars.compile<NewUserCallContext>(source);
    return template(context);
  }
}
