import { Injectable, UnauthorizedException } from '@nestjs/common';
import { Request } from 'express';

interface AttemptInfo {
  count: number;
  lastAttempt: Date;
  blockedUntil?: Date;
}

@Injectable()
export class LoginAttemptService {
  private attempts: Map<string, AttemptInfo> = new Map();
  private readonly maxAttempts = 5;
  private readonly blockDurationMs = 60 * 60 * 1000; // 1 hora

  // Identificador por IP + User-Agent
  getIdentifier(req: Request): string {
    const ip = req.ip || req.connection.remoteAddress || 'unknown';
    const userAgent = req.headers['user-agent'] || '';
    return `${ip}::${userAgent}`;
  }

  async shouldBlock(identifier: string): Promise<void> {
    const info = this.attempts.get(identifier);

    if (info?.blockedUntil && info.blockedUntil > new Date()) {
      const minutesLeft = Math.ceil(
        (info.blockedUntil.getTime() - Date.now()) / 60000,
      );
      throw new UnauthorizedException(
        `Bloqueado por excesso de tentativas. Tente novamente em ${minutesLeft} minutos.`,
      );
    }
    return Promise.resolve();
  }

  async registerFailure(identifier: string): Promise<void> {
    const now = new Date();
    const info = this.attempts.get(identifier) || {
      count: 0,
      lastAttempt: now,
    };

    info.count += 1;
    info.lastAttempt = now;

    if (info.count >= this.maxAttempts) {
      info.blockedUntil = new Date(now.getTime() + this.blockDurationMs);
    }

    this.attempts.set(identifier, info);

    // Opcional: mensagens adicionais nas tentativas 3 e 4
    if (info.count === 3 || info.count === 4) {
      const remaining = this.maxAttempts - info.count;
      throw new UnauthorizedException(
        `Credenciais inválidas. Após mais ${remaining} tentativa(s), o login será bloqueado por 1 hora.`,
      );
    }

    if (info.count >= this.maxAttempts) {
      throw new UnauthorizedException(
        'Você excedeu o número máximo de tentativas. Tente novamente em 1 hora.',
      );
    }

    return Promise.resolve();
  }

  async resetAttempts(identifier: string): Promise<void> {
    this.attempts.delete(identifier);
    return Promise.resolve();
  }
}
