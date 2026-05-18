import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';

@Injectable()
export class TransactionsService {
    constructor(private prisma: PrismaService) {}

    //create transaction
    async createTransaction(dto: CreateTransactionDto, userId: number) {
        const transaction = await this.prisma.transaction.create({
            data: {
                amount: dto.amount,
                type: dto.type,
                note: dto.note,
                date: new Date(dto.date),
                categoryId: dto.categoryId,
                userId: userId,
            },
        });
        return {
            id: transaction.id,
            amount: transaction.amount,
            type: transaction.type,
            note: transaction.note,
            date: transaction.date,
            categoryId: transaction.categoryId,
            createdAt: transaction.createdAt, 
        };
    }

    //get transaction
    async getTransactions(userId: number, date?: string) {
        const filterDate = date ? new Date(date) : new Date();

        const startOfTheDay = new Date(filterDate);
        startOfTheDay.setHours(0, 0, 0, 0);
        
        const endOfTheDay = new Date(filterDate);
        endOfTheDay.setHours(23, 59, 59, 999);

        const transactions = await this.prisma.transaction.findMany({
            where: {
                userId: userId,
                date: {
                    gte: startOfTheDay,
                    lte: endOfTheDay,
                },
            },
        });

        return transactions.map((transaction) => ({
            id: transaction.id,
            amount: transaction.amount,
            type: transaction.type,
            date: transaction.date,
            categoryId: transaction.categoryId,
        }));
    }

    //getTransactionById
    async getTransactionById(id: number, userId: number) {
        const transaction = await this.validateTransaction(id, userId);

        return {
            id: transaction.id,
            amount: transaction.amount,
            type: transaction.type,
            note: transaction.note,
            date: transaction.date,
            categoryId: transaction.categoryId,
            createdAt: transaction.createdAt,
        };
    }

    //update transaction
    async updateTransaction(id: number, userId: number, dto: UpdateTransactionDto) {
        const transaction = await this.validateTransaction(id, userId);

        await this.prisma.transaction.update({
            where: {
                id: id,
            },
            data: {
                amount: dto.amount,
                type: dto.type,
                note: dto.note,
                date: dto.date? new Date(dto.date) : transaction.date,
                categoryId: dto.categoryId,
            },
        });

        return {
            message: 'Transaction updated successfully',
        };
    }

    //delete transaction
    async deleteTransaction(id: number, userId: number) {
        await this.validateTransaction(id, userId);

        await this.prisma.transaction.delete({
            where: {
                id: id,
            },
        });

        return {
            message: 'Transaction deleted successfully',
        };  
    }

    private async validateTransaction(id: number, userId: number) {
        const transaction = await this.prisma.transaction.findFirst({
            where: {
                id: id,
                userId: userId,
            },
        });
        
        if (!transaction) {
            throw new NotFoundException('Transaction not found');
        }
        
        return transaction;
    }
}
