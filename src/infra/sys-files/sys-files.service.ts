import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { CreateSysFileDto } from './dto/create-sys-file.dto';
import { UpdateSysFileDto } from './dto/update-sys-file.dto';
import { ResponseSysFileDto } from './dto/response-sys-file.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { SysFilesEntity } from './entities/sys-file.entity';
import {
  Repository,
  MoreThanOrEqual,
  MoreThan,
  LessThanOrEqual,
} from 'typeorm';
import { SysFilesTipo } from './enums/sys-files-tipo.enum';
import { plainToInstance } from 'class-transformer';
import { SqlFilesService } from '../sql-files/sql-files.service';
import { SqlFilesTipo } from '../sql-files/enums/sql-files-tipo.enum';

@Injectable()
export class SysFilesService {
  constructor(
    @InjectRepository(SysFilesEntity)
    @Inject(SqlFilesService)
    private readonly sysFilesRepo: Repository<SysFilesEntity>,
    private readonly sqlFilesService: SqlFilesService,
  ) {}

  async create(
    createSysFileDto: CreateSysFileDto,
  ): Promise<ResponseSysFileDto> {
    const maxVersion =
      (await this.sqlFilesService.getMaxVersionByType(
        createSysFileDto.idSystem || 0,
        createSysFileDto.tipo === SysFilesTipo.UPDATE
          ? SqlFilesTipo.UPDATE
          : SqlFilesTipo.FULL,
      )) || 0;

    const sysFile = this.sysFilesRepo.create({
      ...createSysFileDto,
      dthrFile: new Date(),
      versaoDb: maxVersion,
    });

    await this.sysFilesRepo.save(sysFile);
    return plainToInstance(ResponseSysFileDto, sysFile);
  }

  async findAll(): Promise<ResponseSysFileDto[]> {
    const sysFiles = await this.sysFilesRepo.find();
    if (!sysFiles.length) throw new NotFoundException('No SysFiles found');
    return sysFiles.map((sysFile) =>
      plainToInstance(ResponseSysFileDto, sysFile),
    );
  }

  async findOneById(id: number): Promise<ResponseSysFileDto> {
    const sysFile = await this.sysFilesRepo.findOne({ where: { idFile: id } });

    if (!sysFile)
      throw new NotFoundException(`SysFile with id ${id} not found`);

    return plainToInstance(ResponseSysFileDto, sysFile);
  }

  async getReleases(
    systemId: string,
    version: string,
    versionDb: string,
  ): Promise<ResponseSysFileDto[]> {
    const sysFiles = await this.sysFilesRepo.find({
      where: {
        idSystem: +systemId,
        versao: MoreThan(+version),
        versaoDb: LessThanOrEqual(+versionDb),
        tipo: SysFilesTipo.UPDATE,
      },
      order: { versao: 'ASC' },
    });
    if (!sysFiles.length)
      throw new NotFoundException(
        `No releases found for version ${version} and versionDb ${versionDb}`,
      );

    return sysFiles.map((file) => plainToInstance(ResponseSysFileDto, file));
  }

  async getFullRelease(
    systemId: string,
    versionDb: string,
  ): Promise<ResponseSysFileDto[]> {
    const sysFiles = await this.sysFilesRepo.find({
      where: {
        idSystem: +systemId,
        versaoDb: LessThanOrEqual(+versionDb),
        tipo: SysFilesTipo.FULL,
      },
      order: { versao: 'DESC' },
    });

    if (!sysFiles.length)
      throw new NotFoundException(
        `No full release found for system ${systemId} and versionDb ${versionDb}`,
      );

    return sysFiles.map((file) => plainToInstance(ResponseSysFileDto, file));
  }

  async findByDays(
    idsystem: number,
    days: number,
  ): Promise<ResponseSysFileDto[]> {
    const date = new Date(Date.now());
    date.setDate(date.getDate() - days);

    const sysFiles = await this.sysFilesRepo.find({
      where: {
        idSystem: +idsystem,
        dthrFile: MoreThanOrEqual(date),
      },
    });

    if (!sysFiles.length)
      throw new NotFoundException(
        `No SysFiles found for system ${idsystem} in the last ${days} days`,
      );

    return sysFiles.map((file) => plainToInstance(ResponseSysFileDto, file));
  }

  async update(
    id: number,
    updates: UpdateSysFileDto,
  ): Promise<ResponseSysFileDto> {
    const sysFile = await this.findOneById(id);
    Object.assign(sysFile, updates);
    await this.sysFilesRepo.save(sysFile);
    if (sysFile.dthrFile && !(sysFile.dthrFile instanceof Date)) {
      sysFile.dthrFile = new Date(sysFile.dthrFile);
    }
    return plainToInstance(ResponseSysFileDto, sysFile);
  }

  async remove(id: number): Promise<void> {
    const result = await this.sysFilesRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`SysFile with id ${id} not found`);
    }
  }
}
