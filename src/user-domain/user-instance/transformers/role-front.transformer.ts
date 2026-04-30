import { ValueTransformer } from 'typeorm';
import { RoleFrontEnum } from '../enums/user-instance-roles.enum';

const ALLOWED = new Set<string>(Object.values(RoleFrontEnum));

export const RoleFrontTransformer: ValueTransformer = {
  to: (value: RoleFrontEnum[] | null | undefined): string => {
    if (!value || value.length === 0) return RoleFrontEnum.NOTALLOW;
    return value.join(',');
  },
  from: (value: string | null | undefined): RoleFrontEnum[] => {
    if (!value) return [RoleFrontEnum.NOTALLOW];
    const parsed = value
      .split(',')
      .map((v) => v.trim())
      .filter((v): v is RoleFrontEnum => ALLOWED.has(v));
    return parsed.length === 0 ? [RoleFrontEnum.NOTALLOW] : parsed;
  },
};
