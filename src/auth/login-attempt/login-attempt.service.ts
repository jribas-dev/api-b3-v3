import { Injectable, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Request } from 'express';
import { LoginAttemptEntity } from './login-attempt.entity';

@Injectable()
export class LoginAttemptService {
  private readonly maxAttempts = 5;
  private readonly blockDurationMs = 60 * 60 * 1000; // 1 hora

  constructor(
    @InjectRepository(LoginAttemptEntity)
    private readonly attemptRepo: Repository<LoginAttemptEntity>,
  ) {}

  getIdentifier(req: Request): string {
    return req.ip || req.connection.remoteAddress || 'unknown';
  }

  async shouldBlock(identifier: string): Promise<void> {
    const record = await this.attemptRepo.findOne({ where: { identifier } });
    if (record?.blockedUntil && record.blockedUntil > new Date()) {
      const minutesLeft = Math.ceil(
        (record.blockedUntil.getTime() - Date.now()) / 60000,
      );
      throw new UnauthorizedException(
        `Bloqueado por excesso de tentativas. Tente novamente em ${minutesLeft} minutos.`,
      );
    }
  }

  async registerFailure(identifier: string): Promise<void> {
    let record = await this.attemptRepo.findOne({ where: { identifier } });

    if (!record) {
      record = this.attemptRepo.create({
        identifier,
        attempts: 0,
        blockedUntil: null,
      });
    }

    record.attempts += 1;

    if (record.attempts >= this.maxAttempts) {
      record.blockedUntil = new Date(Date.now() + this.blockDurationMs);
      await this.attemptRepo.save(record);
      throw new UnauthorizedException(
        'Você excedeu o número máximo de tentativas. Tente novamente em 1 hora.',
      );
    }

    await this.attemptRepo.save(record);

    if (record.attempts === 3 || record.attempts === 4) {
      const remaining = this.maxAttempts - record.attempts;
      throw new UnauthorizedException(
        `Credenciais inválidas. Após mais ${remaining} tentativa(s), o login será bloqueado por 1 hora.`,
      );
    }
  }

  async resetAttempts(identifier: string): Promise<void> {
    await this.attemptRepo.delete({ identifier });
  }
}
