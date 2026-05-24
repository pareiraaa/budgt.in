import { TransactionType } from "@prisma/client"

export class CreateTransactionDto {
    amount!: number;
    type!: TransactionType;
    note?: string;
    date!: string;
    pocketId?: number;
    incomeSource?: string;
    incomeSourceNote?: string;
    coverFromPocketId?: number;
}