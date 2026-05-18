import { TransactionType } from "@prisma/client"

export class CreateCategoryDto {
    categoryName!: string
    type!: TransactionType
}