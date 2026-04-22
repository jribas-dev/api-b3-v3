import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { Brackets } from 'typeorm';
import { SellerContextService } from 'src/b3vendas/shared/seller-context.service';
import { TenantService } from 'src/tenant/tenant.service';
import { ClienteEntity } from './entities/cliente.entity';
import { CreateClienteDto } from './dto/create-cliente.dto';
import { UpdateClienteDto } from './dto/update-cliente.dto';
import { ResponseClienteBuscaDto } from './dto/response-cliente-busca.dto';
import { ResponseClienteInfoDto } from './dto/response-cliente-info.dto';

function padLeft(value: number, length: number): string {
  return String(value).padStart(length, '0');
}

@Injectable()
export class ClienteService {
  constructor(
    private readonly tenantService: TenantService,
    private readonly sellerContextService: SellerContextService,
  ) {}

  async buscar(
    dbId: string,
    userId: string,
    termo: string,
  ): Promise<ResponseClienteBuscaDto[]> {
    if (!termo || termo.trim().length < 2) {
      throw new BadRequestException(
        'Informe ao menos 2 caracteres para a busca',
      );
    }

    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);
    const termoUpper = termo.toUpperCase();
    const like = `%${termoUpper}%`;

    const rows = await ds
      .getRepository(ClienteEntity)
      .createQueryBuilder('a')
      .select(['a.id', 'a.razao'])
      .leftJoin('cntclasses', 'cc', 'cc.idcnt = a.id')
      .leftJoin('cntclass', 'cl', 'cl.id = cc.idclass')
      .where('a.ativo')
      .andWhere('a.idvend = :vendId', { vendId })
      .andWhere('cl.ativo')
      .andWhere(
        new Brackets((qb) =>
          qb
            .where('UPPER(a.razao) LIKE :like', { like })
            .orWhere('a.docfed LIKE :like', { like }),
        ),
      )
      .distinct(true)
      .orderBy('a.razao', 'ASC')
      .limit(50)
      .getMany();

    return rows.map((r) =>
      plainToInstance(ResponseClienteBuscaDto, {
        id: r.id,
        razao: r.razao,
        display: `[${padLeft(r.id, 5)}] ${r.razao}`,
      }),
    );
  }

  async info(dbId: string, id: number): Promise<ResponseClienteInfoDto> {
    const cliente = await this.findOneOrFail(dbId, id);
    return plainToInstance(ResponseClienteInfoDto, cliente);
  }

  async create(
    dbId: string,
    userId: string,
    dto: CreateClienteDto,
  ): Promise<ResponseClienteInfoDto> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(ClienteEntity);

    const entity = repo.create({ ...dto, idvend: vendId, ativo: true });
    const saved = await repo.save(entity);
    return plainToInstance(ResponseClienteInfoDto, saved);
  }

  async update(
    dbId: string,
    userId: string,
    id: number,
    dto: UpdateClienteDto,
  ): Promise<ResponseClienteInfoDto> {
    const cliente = await this.assertVinculoVendedor(dbId, userId, id);
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(ClienteEntity);

    if (dto.razao !== undefined) cliente.razao = dto.razao;
    if (dto.fantasia !== undefined) cliente.fantasia = dto.fantasia;
    if (dto.docfed !== undefined) cliente.docfed = dto.docfed;
    if (dto.docest !== undefined) cliente.docest = dto.docest;
    if (dto.email !== undefined) cliente.email = dto.email;
    if (dto.site !== undefined) cliente.site = dto.site;
    if (dto.cep !== undefined) cliente.cep = dto.cep;
    if (dto.endereco !== undefined) cliente.endereco = dto.endereco;
    if (dto.nroend !== undefined) cliente.nroend = dto.nroend;
    if (dto.bairro !== undefined) cliente.bairro = dto.bairro;
    if (dto.cidade !== undefined) cliente.cidade = dto.cidade;
    if (dto.uf !== undefined) cliente.uf = dto.uf;
    if (dto.fone !== undefined) cliente.fone = dto.fone;
    if (dto.fone2 !== undefined) cliente.fone2 = dto.fone2;
    if (dto.cel !== undefined) cliente.cel = dto.cel;
    if (dto.obsvenda !== undefined) cliente.obsvenda = dto.obsvenda;
    if (dto.idoper !== undefined) cliente.idoper = dto.idoper;
    const saved = await repo.save(cliente);
    return plainToInstance(ResponseClienteInfoDto, saved);
  }

  async remove(dbId: string, id: number): Promise<{ id: number }> {
    const ds = await this.tenantService.getDataSource(dbId);
    const repo = ds.getRepository(ClienteEntity);
    const cliente = await repo.findOneBy({ id });
    if (!cliente) throw new NotFoundException(`Cliente ${id} não encontrado`);

    await repo.remove(cliente);
    return { id };
  }

  private async findOneOrFail(
    dbId: string,
    id: number,
  ): Promise<ClienteEntity> {
    const ds = await this.tenantService.getDataSource(dbId);
    const cliente = await ds.getRepository(ClienteEntity).findOneBy({ id });
    if (!cliente) throw new NotFoundException(`Cliente ${id} não encontrado`);
    return cliente;
  }

  private async assertVinculoVendedor(
    dbId: string,
    userId: string,
    id: number,
  ): Promise<ClienteEntity> {
    const { vendId } = await this.sellerContextService.resolve(dbId, userId);
    const cliente = await this.findOneOrFail(dbId, id);
    if (cliente.idvend !== vendId) {
      throw new ForbiddenException(
        'Somente o vendedor vinculado ao cliente pode alterá-lo',
      );
    }
    return cliente;
  }
}
