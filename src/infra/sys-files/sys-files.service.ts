import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateSysFileDto } from './dto/create-sys-file.dto';
import { UpdateSysFileDto } from './dto/update-sys-file.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { SysFilesEntity } from './entities/sys-file.entity';
import {
  Repository,
  MoreThanOrEqual,
  MoreThan,
  LessThanOrEqual,
} from 'typeorm';

@Injectable()
export class SysFilesService {
  constructor(
    @InjectRepository(SysFilesEntity)
    private readonly sysFilesRepo: Repository<SysFilesEntity>,
  ) {}

  async create(createSysFileDto: CreateSysFileDto): Promise<SysFilesEntity> {
    const sysFile = this.sysFilesRepo.create(createSysFileDto);
    return this.sysFilesRepo.save(sysFile);
  }

  async findAll(): Promise<SysFilesEntity[]> {
    return this.sysFilesRepo.find({ relations: ['idSystem'] });
  }

  async findOneById(id: number): Promise<SysFilesEntity> {
    const sysFile = await this.sysFilesRepo.findOne({ where: { idFile: id } });

    if (!sysFile)
      throw new NotFoundException(`SysFile with id ${id} not found`);

    return sysFile;
  }

  async getMinorReleases(
    systemId: string,
    version: string,
  ): Promise<SysFilesEntity[]> {
    const sysFile = await this.sysFilesRepo.findOne({
      where: { idSystem: +systemId, versao: +version },
    });

    if (!sysFile) throw new NotFoundException(`Version ${version} not found`);

    const versionDb = sysFile.versaoDb.toString();
    const sysFiles = await this.sysFilesRepo.find({
      where: {
        idSystem: +systemId,
        versaoDb: +versionDb,
        tipo: 'U',
        versao: MoreThan(+version),
      },
    });
    if (!sysFiles.length)
      throw new NotFoundException(
        `No minor releases found for version ${versionDb}`,
      );

    return sysFiles;
  }

  async getMajorReleases(
    systemId: string,
    version: string,
    versionDb: string,
  ): Promise<SysFilesEntity[]> {
    const sysFiles = await this.sysFilesRepo.find({
      where: {
        idSystem: +systemId,
        versao: MoreThan(+version),
        versaoDb: LessThanOrEqual(+versionDb),
        tipo: 'U',
      },
    });
    if (!sysFiles.length)
      throw new NotFoundException(
        `No major releases found for version ${version} and versionDb ${versionDb}`,
      );

    return sysFiles;
  }

  async findByDays(idsystem: number, days: number): Promise<SysFilesEntity[]> {
    const date = new Date(Date.now());
    date.setDate(date.getDate() - days);

    return this.sysFilesRepo.find({
      where: { idSystem: idsystem, dthrFile: MoreThanOrEqual(date) },
    });
  }

  async update(id: number, updates: UpdateSysFileDto) {
    const sysFile = await this.findOneById(id);
    Object.assign(sysFile, updates);
    return this.sysFilesRepo.save(sysFile);
  }

  async remove(id: number): Promise<void> {
    const sysFile = await this.findOneById(id);
    await this.sysFilesRepo.remove(sysFile);
  }
}
