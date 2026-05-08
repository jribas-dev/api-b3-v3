import { ValueTransformer } from 'typeorm';
import { RoleFrontEnum } from '../enums/user-instance-roles.enum';

const ALLOWED = new Set<string>(Object.values(RoleFrontEnum));

export const RoleFrontTransformer: ValueTransformer = {
  to: (value: RoleFrontEnum[] | string | null | undefined): string => {
    if (value == null) return RoleFrontEnum.NOTALLOW;
    if (typeof value === 'string') {
      return value.length === 0 ? RoleFrontEnum.NOTALLOW : value;
    }
    if (value.length === 0) return RoleFrontEnum.NOTALLOW;
    return value.join(',');
  },
  from: (
    value: string | RoleFrontEnum[] | null | undefined,
  ): RoleFrontEnum[] => {
    if (value == null) return [RoleFrontEnum.NOTALLOW];
    const tokens = Array.isArray(value)
      ? value.map((v) => String(v).trim())
      : value.split(',').map((v) => v.trim());
    const parsed = tokens.filter((v): v is RoleFrontEnum => ALLOWED.has(v));
    return parsed.length === 0 ? [RoleFrontEnum.NOTALLOW] : parsed;
  },
};
