import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { RolesFront } from 'src/auth/decorators/roles-front.decorator';
import { JwtGuard } from 'src/auth/guards/jwt.guard';
import { RolesFrontGuard } from 'src/auth/guards/roles-front.guard';
import { UserInstanceGuard } from 'src/auth/guards/user-instance.guard';
import {
  RoleFront,
  RoleFrontEnum,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { EquipeService } from './equipe.service';
import { CreateEquipeDto } from './dto/create-equipe.dto';

@Controller('b3vendas/equipe')
@UseGuards(JwtGuard, UserInstanceGuard, RolesFrontGuard)
export class EquipeController {
  constructor(private readonly equipeService: EquipeService) {}

  @Get()
  @RolesFront(RoleFrontEnum.SUPERSALER, RoleFrontEnum.SALER)
  async listar(
    @Request()
    req: {
      user: { userId: string; dbId: string; roleFront: RoleFront };
    },
  ) {
    return this.equipeService.listar(
      req.user.dbId,
      req.user.userId,
      req.user.roleFront,
    );
  }

  @Get('sem-equipe')
  @RolesFront(RoleFrontEnum.SUPERSALER)
  async semEquipe(@Request() req: { user: { userId: string; dbId: string } }) {
    return await this.equipeService.semEquipe(req.user.dbId, req.user.userId);
  }

  @Post()
  @RolesFront(RoleFrontEnum.SUPERSALER)
  @HttpCode(HttpStatus.CREATED)
  async inserir(
    @Request() req: { user: { userId: string; dbId: string } },
    @Body() dto: CreateEquipeDto,
  ) {
    await this.equipeService.inserir(
      req.user.dbId,
      req.user.userId,
      dto.idcntliderado,
    );
  }

  @Delete(':id')
  @RolesFront(RoleFrontEnum.SUPERSALER)
  @HttpCode(HttpStatus.NO_CONTENT)
  async remover(
    @Request() req: { user: { userId: string; dbId: string } },
    @Param('id', ParseIntPipe) idcntliderado: number,
  ) {
    await this.equipeService.remover(
      req.user.dbId,
      req.user.userId,
      idcntliderado,
    );
  }
}
