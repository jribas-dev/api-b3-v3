export class GridResponseDto<T> {
  total: number;
  page: number;
  limit: number;
  items: T[];
}
