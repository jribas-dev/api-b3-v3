import { BadRequestException } from '@nestjs/common';
import { RoleFrontEnum } from '../enums/user-instance-roles.enum';

export function assertRoleFrontConsistent(
  roles: RoleFrontEnum[] | null | undefined,
): void {
  if (!roles || roles.length === 0) return;

  if (
    roles.includes(RoleFrontEnum.SALER) &&
    roles.includes(RoleFrontEnum.SUPERSALER)
  ) {
    throw new BadRequestException(
      'roleFront inválido: SALER e SUPERSALER não podem coexistir no mesmo vínculo',
    );
  }
}
