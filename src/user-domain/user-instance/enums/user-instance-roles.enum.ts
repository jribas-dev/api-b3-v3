export enum RoleBack {
  ADMIN = 'admin',
  SUPER = 'supervisor',
  USER = 'user',
  NOTALLOW = 'notallow',
}

export enum RoleFrontEnum {
  ADMIN = 'admin',
  SUPERSALER = 'supersaler',
  SALER = 'saler',
  INVENTORY = 'inventory',
  BUYER = 'buyer',
  NOTALLOW = 'notallow',
}

export type RoleFront = RoleFrontEnum[];
