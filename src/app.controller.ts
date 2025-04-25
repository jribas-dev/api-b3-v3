import {
  Controller,
  Get,
  Param,
  NotFoundException,
  UseGuards,
  Req,
} from '@nestjs/common';
import { AppService } from './app.service';
import {
  RoleBack,
  RoleFront,
} from './user-instance/enums/user-instance-roles.enum';
import { JwtGuard } from './auth/guards/jwt.guard';

type EnumMap = {
  [key: string]: Record<string, string>;
};

@Controller('backend')
export class AppController {
  private readonly enumMap: EnumMap = {
    roleback: RoleBack,
    rolefront: RoleFront,
    // Se quiser adicionar mais enums no futuro, é só colocar aqui.
  };
  constructor(private readonly appService: AppService) {}

  @Get('hello')
  getHello(): string {
    return this.appService.getHello();
  }

  @UseGuards(JwtGuard)
  @Get('session')
  getSession(
    @Req()
    req: Request & {
      user: {
        userId: string;
        email: string;
        isRoot: boolean;
        dbId: string | undefined;
        instanceName: string | undefined;
      };
    },
  ) {
    const user = req.user;
    return user;
  }

  @UseGuards(JwtGuard)
  @Get('enums/:enum')
  getEnumValues(@Param('enum') enumName: string): string[] {
    if (!enumName) {
      throw new NotFoundException('Enum não especificado.');
    }
    const key = enumName.toLowerCase();
    const enumObj = this.enumMap[key];

    if (!enumObj) {
      throw new NotFoundException(`Enum "${enumName}" não encontrado.`);
    }

    return Object.values(enumObj);
  }
}
