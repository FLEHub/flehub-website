declare module 'rwanda-geo-structure' {
  export function getProvinces(): string[];
  export function getDistrictsByProvince(province: string): string[];
  export function getSectorsByDistrict(province: string, district: string): string[];
  export function getCellsBySector(province: string, district: string, sector: string): string[];
  export function getVillagesByCell(province: string, district: string, sector: string, cell: string): string[];
}
