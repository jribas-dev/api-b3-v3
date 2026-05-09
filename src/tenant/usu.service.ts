import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { TenantService } from './tenant.service';
import { EmpService } from './emp.service';
import { UsuBackofficeDto } from './dto/usu-backoffice.dto';
import { UsuUpdateDto } from './dto/usu-update.dto';

@Injectable()
export class UsuService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly empService: EmpService,
  ) {}

  private async validateIdemp(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<void> {
    const emitentes = await this.empService.listEmitentes(dbId, userId);
    if (!emitentes.some((e) => e.id === idemp)) {
      throw new ForbiddenException('Empresa não autorizada para este usuário');
    }
  }

  async listBackoffice(
    dbId: string,
    userId: string,
    idemp: number,
  ): Promise<UsuBackofficeDto[]> {
    await this.validateIdemp(dbId, userId, idemp);
    const ds = await this.tenantService.getDataSource(dbId);

    const rows = await ds.query<Array<{ id: number | string; login: string }>>(
      `SELECT u.id, u.login
       FROM usu u
       INNER JOIN usuemp ue ON ue.idusu = u.id
       WHERE u.userId IS NULL
         AND NOT u.inativo
         AND ue.idcnt = ?
       ORDER BY u.login`,
      [idemp],
    );

    return rows.map((r) => ({
      id: Number(r.id),
      login: String(r.login ?? ''),
    }));
  }

  async update(
    dbId: string,
    authUserId: string,
    id: number,
    body: UsuUpdateDto,
  ): Promise<void> {
    if (body.userId !== authUserId) {
      throw new ForbiddenException('userId não corresponde à sessão');
    }

    const ds = await this.tenantService.getDataSource(dbId);

    const target = await ds.query<Array<{ ok: number }>>(
      `SELECT 1 AS ok FROM usu WHERE id = ?`,
      [id],
    );
    if (target.length === 0) {
      throw new NotFoundException('Usuário do legado não encontrado');
    }

    const fields: string[] = [];
    const values: (string | null)[] = [];

    if (body.userId !== undefined) {
      fields.push('userId = ?');
      values.push(body.userId);
    }
    if (body.nome !== undefined) {
      fields.push('nome = ?');
      values.push(body.nome);
    }
    if (body.email !== undefined) {
      fields.push('email = ?');
      values.push(body.email);
    }
    if (body.telefone !== undefined) {
      fields.push('telefone = ?');
      values.push(body.telefone);
    }

    if (fields.length === 0) {
      return;
    }

    values.push(String(id));
    await ds.query(`UPDATE usu SET ${fields.join(', ')} WHERE id = ?`, values);
  }
}
