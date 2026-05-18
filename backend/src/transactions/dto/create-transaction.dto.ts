import { TransactionType } from "@prisma/client"

export class CreateTransactionDto {
    amount!: number
    type!: TransactionType
    note?: string
    date!: string 
    categoryId!: number
}