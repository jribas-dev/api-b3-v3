import { Injectable } from '@nestjs/common';

interface AttemptInfo {
  attempts: number;
  lastAttempt: Date;
  blockedUntil?: Date;
}

@Injectable()
export class LoginAttemptService {
  private attemptsMap: Map<string, AttemptInfo> = new Map();
  private readonly MAX_ATTEMPTS = 5;
  private readonly BLOCK_DURATION_MS = 60 * 60 * 1000; // 1 hora

  private getClientId(ip: string, userAgent: string): string {
    return `${ip}::${userAgent}`;
  }

  public registerFailedAttempt(ip: string, userAgent: string): string | null {
    const key = this.getClientId(ip, userAgent);
    const now = new Date();
    const attempt = this.attemptsMap.get(key) || {
      attempts: 0,
      lastAttempt: now,
    };

    attempt.attempts += 1;
    attempt.lastAttempt = now;

    if (attempt.attempts >= this.MAX_ATTEMPTS) {
      attempt.blockedUntil = new Date(now.getTime() + this.BLOCK_DURATION_MS);
    }

    this.attemptsMap.set(key, attempt);

    if (attempt.attempts === 3 || attempt.attempts === 4) {
      return `⚠️ Atenção: após ${this.MAX_ATTEMPTS} tentativas sua conta será bloqueada por 1 hora.`;
    }

    return null;
  }

  public isBlocked(ip: string, userAgent: string): boolean {
    const key = this.getClientId(ip, userAgent);
    const attempt = this.attemptsMap.get(key);
    if (!attempt || !attempt.blockedUntil) return false;
    if (new Date() > attempt.blockedUntil) {
      this.attemptsMap.delete(key); // desbloqueia
      return false;
    }
    return true;
  }

  public clearAttempts(ip: string, userAgent: string) {
    const key = this.getClientId(ip, userAgent);
    this.attemptsMap.delete(key);
  }
}
