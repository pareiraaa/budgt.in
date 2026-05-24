import { PocketType } from '@prisma/client';    

export class CreatePocketDto {
  name!: string;
  pocketType!: PocketType;
  targetAmount?: number;
  deadline?: string;
}
