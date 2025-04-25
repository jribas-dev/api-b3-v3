export interface JwtPayload {
  sub: string; // userId
  email: string;
  isRoot: boolean;
  instanceName?: string; // Optional, only for user instances
  dbId?: string; // Optional, only for user instances
}
