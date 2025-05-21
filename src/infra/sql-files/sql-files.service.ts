import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateSqlFileDto } from './dto/create-sql-file.dto';
import { UpdateSqlFileDto } from './dto/update-sql-file.dto';
import { SqlFilesEntity } from './entities/sql-file.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { MoreThanOrEqual, Repository } from 'typeorm';
import { SqlFilesTipo } from './enums/sql-files-tipo.enum';
import { ResponseSqlFileDto } from './dto/response-sql-file.dto';
import { plainToInstance } from 'class-transformer';

@Injectable()
export class SqlFilesService {
  constructor(
    @InjectRepository(SqlFilesEntity)
    private readonly sqlFilesRepo: Repository<SqlFilesEntity>,
  ) {}

  async create(
    createSqlFileDto: CreateSqlFileDto,
  ): Promise<ResponseSqlFileDto> {
    const sqlFile = this.sqlFilesRepo.create({
      ...createSqlFileDto,
      dthrSql: new Date(),
    });
    await this.sqlFilesRepo.save(sqlFile);
    return plainToInstance(ResponseSqlFileDto, sqlFile);
  }

  async findAll(): Promise<ResponseSqlFileDto[]> {
    const sqlFiles = await this.sqlFilesRepo.find();
    if (!sqlFiles.length) {
      throw new NotFoundException('No SQL files found');
    }
    return sqlFiles.map((sqlFile) =>
      plainToInstance(ResponseSqlFileDto, sqlFile),
    );
  }

  async findOneById(idSql: number): Promise<ResponseSqlFileDto> {
    const sqlFile = await this.sqlFilesRepo.findOne({ where: { idSql } });
    if (!sqlFile) {
      throw new NotFoundException(`SqlFile with id ${idSql} not found`);
    }
    return plainToInstance(ResponseSqlFileDto, sqlFile);
  }

  async findByDays(
    idSystem: number,
    days: number,
  ): Promise<ResponseSqlFileDto[]> {
    const date = new Date(Date.now());
    date.setDate(date.getDate() - days);
    const sqlFiles = await this.sqlFilesRepo.find({
      where: {
        idSystem,
        dthrSql: MoreThanOrEqual(date),
      },
    });
    if (!sqlFiles.length) {
      throw new NotFoundException(
        `No SQL files found for system ${idSystem} in the last ${days} days`,
      );
    }
    return sqlFiles.map((sqlFile) =>
      plainToInstance(ResponseSqlFileDto, sqlFile),
    );
  }

  async getReleasesFrom(
    systemId: number,
    fromVersion: number | null,
  ): Promise<ResponseSqlFileDto[]> {
    if (!fromVersion) {
      fromVersion = 0.0;
    }
    const sqlFiles = await this.sqlFilesRepo.find({
      where: {
        idSystem: systemId,
        versaoDb: MoreThanOrEqual(fromVersion),
        tipo: SqlFilesTipo.UPDATE,
      },
      order: { versaoDb: 'ASC' },
    });
    if (!sqlFiles.length) {
      throw new NotFoundException(
        `No SQL files found for system ${systemId} with version greater than or equal to ${fromVersion}`,
      );
    }
    return sqlFiles.map((sqlFile) =>
      plainToInstance(ResponseSqlFileDto, sqlFile),
    );
  }

  async getMaxVersionByType(
    systemId: number,
    tipo: SqlFilesTipo,
  ): Promise<number | null> {
    const maxVersion = await this.sqlFilesRepo
      .createQueryBuilder('sqlFile')
      .select('MAX(sqlFile.versaoDb)', 'maxVersion')
      .where('sqlFile.idSystem = :systemId', { systemId })
      .andWhere('sqlFile.tipo = :tipo', { tipo })
      .getRawOne<{ maxVersion: number | null }>();
    if (!maxVersion) {
      return null;
    }
    return maxVersion.maxVersion;
  }

  async getLastFullRelease(systemId: number): Promise<ResponseSqlFileDto> {
    const maxVersion = await this.getMaxVersionByType(
      systemId,
      SqlFilesTipo.FULL,
    );
    if (!maxVersion || maxVersion === null) {
      throw new NotFoundException(
        `No full release found for system ${systemId}`,
      );
    }
    const sqlFile = await this.sqlFilesRepo.findOne({
      where: {
        idSystem: +systemId,
        versaoDb: maxVersion,
        tipo: SqlFilesTipo.FULL,
      },
    });
    if (!sqlFile) {
      throw new NotFoundException(
        `No SQL file found for system ${systemId} with version ${maxVersion}`,
      );
    }
    return plainToInstance(ResponseSqlFileDto, sqlFile);
  }

  async getSQLBinary(idSql: number): Promise<Buffer> {
    const sqlFile = await this.sqlFilesRepo.findOne({
      where: { idSql },
      select: ['script'],
    });
    if (!sqlFile) {
      throw new NotFoundException(`SQL file with id ${idSql} not found`);
    }
    if (!sqlFile.script) {
      throw new NotFoundException(`SQL file with id ${idSql} has empty script`);
    }
    return sqlFile.script;
  }

  async update(
    id: number,
    updateSqlFileDto: UpdateSqlFileDto,
  ): Promise<ResponseSqlFileDto> {
    const sqlFile = this.sqlFilesRepo.create(updateSqlFileDto);
    Object.assign(sqlFile, updateSqlFileDto);
    await this.sqlFilesRepo.save(sqlFile);
    return plainToInstance(ResponseSqlFileDto, sqlFile);
  }

  async remove(id: number): Promise<void> {
    const result = await this.sqlFilesRepo.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`SqlFile with id ${id} not found`);
    }
  }
}
