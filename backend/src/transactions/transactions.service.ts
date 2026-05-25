import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';
import { PocketType, TransactionStatus, TransactionType } from '@prisma/client';

@Injectable()
export class TransactionsService {
    constructor(private prisma: PrismaService) {}

    //create transaction
    async createTransaction(dto: CreateTransactionDto, userId: number) {
        if(dto.type === TransactionType.Income){
            return this.createIncome(dto, userId);
        } else {
            return this.createExpense(dto, userId);
        }
    }

    async createIncome(dto: CreateTransactionDto, userId: number) {
        const mainPocket = await this.prisma.pocket.findFirst({
            where: {
                userId: userId,
                pocketType: PocketType.Main,
                deletedAt: null,
            },
        });

        if (!mainPocket) {
            throw new NotFoundException('Main pocket not found');
        }
        
        const transaction = await this.prisma.$transaction(async (tx) => {
            const createdTransaction = await tx.transaction.create({
                data: {
                    amount: dto.amount,
                    type: TransactionType.Income,
                    note: dto.note,
                    date: new Date(dto.date),
                    userId: userId,
                    pocketId: mainPocket.id,
                    pocketNameShot: mainPocket.pocketName,
                    incomeSource: dto.incomeSource,
                    incomeSourceNote: dto.incomeSourceNote,
                    isTransfer: false,
                },
            });

            await tx.pocket.update({
                where: {
                    id: mainPocket.id,
                },
                data: {
                    balance: {
                        increment: dto.amount,
                    },
                },
            });

            return createdTransaction;
        });

        return {
            message: 'Income transaction created successfully',
            transactionId: transaction.id,
        };
    }

    async createExpense(dto: CreateTransactionDto, userId: number){
        if(!dto.pocketId){
            throw new BadRequestException('Pocket ID is required');
        }

        const pocket = await this.prisma.pocket.findFirst({
            where:{
                id: dto.pocketId,
                userId: userId,
                deletedAt: null
            }
        })

        if(!pocket){
            throw new NotFoundException('Pocket not found')
        }

        const shortage = dto.amount - pocket.balance;

        let coverPocket: {
            id: number,
            pocketName: string,
            balance: number
        } | null = null

        if(shortage > 0){
            if(!dto.coverFromPocketId){
                throw new BadRequestException('Insufficient balance, choose pocket to cover');
            }

            if(dto.coverFromPocketId === dto.pocketId){
                throw new BadRequestException("Cant be the same pocket");
            }

            coverPocket = await this.prisma.pocket.findFirst({
                where: {
                    id: dto.coverFromPocketId,
                    userId: userId,
                    deletedAt: null
                }
            })

            if(!coverPocket){
                throw new NotFoundException("Cover pocket not found");
            }

            if(coverPocket.balance < shortage){
                throw new BadRequestException("Insufficient cover pocket balance");
            }
        }

        const transaction = await this.prisma.$transaction(async (tx) => {
            if(shortage>0 && coverPocket){
                await tx.transaction.create({
                    data: {
                        amount: shortage,
                        type: TransactionType.Expense,
                        note: `Cover to ${pocket.pocketName}`,
                        date: new Date(),
                        userId: userId,
                        pocketId: coverPocket.id,
                        pocketNameShot: coverPocket.pocketName,
                        isTransfer: true,
                    }
                })

                await tx.transaction.create({
                    data: {
                        amount: shortage,
                        type: TransactionType.Income,
                        note: `Cover from ${coverPocket.pocketName}`,
                        date: new Date(),
                        userId: userId,
                        pocketId: pocket.id,
                        pocketNameShot: pocket.pocketName,
                        isTransfer: true,
                    }
                })

                await tx.pocket.update({
                    where:{
                        id: coverPocket.id
                    }, 
                    data:{
                        balance: {
                            decrement: shortage
                        }
                    }
                })

                await tx.pocket.update({
                    where:{
                        id: pocket.id
                    }, 
                    data:{
                        balance: {
                            increment: shortage
                        }
                    }
                })
            }

            const createdTransaction = await tx.transaction.create({
                data: {
                    amount: dto.amount,
                    type: TransactionType.Expense,
                    note: dto.note,
                    date: new Date(dto.date),
                    userId: userId,
                    pocketId: pocket.id,
                    pocketNameShot: pocket.pocketName,
                    isTransfer: false,
                }
            })

            await tx.pocket.update({
                where:{
                    id: pocket.id
                },
                data:{
                    balance: {
                        decrement: dto.amount
                    }
                }
            })

            return createdTransaction
        })

        return {
            message: 'Expense transaction created',
            transactionId: transaction.id
        }
    }

    //get transaction
    async getTransactions(userId: number, date?: string) {
        // const filterDate = date ? new Date(date) : new Date();

        // const startOfTheDay = new Date(filterDate);
        // startOfTheDay.setHours(0, 0, 0, 0);
        
        // const endOfTheDay = new Date(filterDate);
        // endOfTheDay.setHours(23, 59, 59, 999);

        const filterDate = date ? new Date(date) : new Date();

        const startOfTheMonth = new Date(filterDate.getFullYear(), filterDate.getMonth(), 1, 0, 0, 0, 0);

        const endOfTheMonth = new Date(filterDate.getFullYear(), filterDate.getMonth() + 1, 0, 23, 59, 59, 999);

        const transactions = await this.prisma.transaction.findMany({
            where: {
                userId: userId,
                date: {
                    gte: startOfTheMonth,
                    lte: endOfTheMonth,
                },
            },
        });

        return transactions.map((transaction) => ({
            id: transaction.id,
            amount: transaction.amount,
            type: transaction.type,
            note: transaction.note,
            incomeSource: transaction.incomeSource,
            date: transaction.date,
            pocketId: transaction.pocketId,
            pocketNameShot: transaction.pocketNameShot,
            isTransfer: transaction.isTransfer,
            status: transaction.status,
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
            pocketId: transaction.pocketId,
            pocketNameShot: transaction.pocketNameShot,
            isTransfer: transaction.isTransfer,
            incomeSource: transaction.incomeSource,
            incomeSourceNote: transaction.incomeSourceNote,
            createdAt: transaction.createdAt
        };
    }

    //update transaction
    async updateTransaction(id: number, userId: number, dto: UpdateTransactionDto) {
        const transaction = await this.validateTransaction(id, userId);

        const fiveMinuteInMilisecond = 5 * 60 * 1000;

        const age = Date.now() - transaction.createdAt.getTime();

        if(age > fiveMinuteInMilisecond){
            throw new BadRequestException('Can be edited in 5 Min');
        }

        if(transaction.isTransfer){
            throw new BadRequestException('Transfer cant be edited')
        }

        const newAmount = dto.amount ?? transaction.amount
        const newType = dto.type ?? transaction.type
        const newPocketId = dto.pocketId ?? transaction.pocketId

        const newPocket = await this.prisma.pocket.findFirst({
            where: { id: newPocketId, userId: userId, deletedAt: null },
        });
            
        if (!newPocket) {
            throw new NotFoundException('Pocket not found');
        }

        const newNote = dto.note ?? transaction.note

        await this.prisma.$transaction(async (tx) => {
            if(transaction.type === TransactionType.Expense){
                await tx.pocket.update({
                    where: {
                        id: transaction.pocketId
                    },
                    data: {
                        balance: {
                            increment: transaction.amount
                        }
                    }
                })
            } else {
                await tx.pocket.update({
                    where: {
                        id: transaction.pocketId
                    }, data: {
                        balance: {
                            decrement: transaction.amount
                        }
                    }
                })
            }

            if (newType === TransactionType.Expense) {
                await tx.pocket.update({
                    where: { 
                        id: newPocketId 
                    },
                    data: { 
                        balance: { 
                            decrement: newAmount 
                        }
                    },
                });
            } else {
                await tx.pocket.update({
                    where: { 
                        id: newPocketId 
                    },
                    data: { 
                        balance: { 
                            increment: newAmount 
                        }
                    },
                });
            }

            await tx.transaction.update({
                where: { id: id },
                data: {
                amount: newAmount,
                type: newType,
                pocketId: newPocketId,
                note: newNote,
                pocketNameShot: newPocket.pocketName,   // snapshot ikut diupdate kalau pocket pindah
                },
            });
        });

        return {
            message: 'Transaction updated successfully',
        };
    }

    //void transaction
    async voidTransaction(id: number, userId: number) {
        const transaction = await this.validateTransaction(id, userId);

        if(transaction.status !== TransactionStatus.Active){
            throw new BadRequestException('Transaction voided')
        }

        if(transaction.isTransfer){
            throw new BadRequestException('Transfer can\'t be voided')
        }

        await this.prisma.$transaction(async (tx) => {
            await tx.transaction.update({
                where: {
                    id: id
                },
                data: {
                    status: TransactionStatus.Voided
                }
            })

            const reverseType = transaction.type === TransactionType.Expense ? TransactionType.Income : TransactionType.Expense

            await tx.transaction.create({
                data:{
                    amount: transaction.amount,
                    type: reverseType,
                    note: `Void: ${transaction.note ?? 'transaksi'}`,
                    date: new Date(),
                    userId: userId,
                    pocketId: transaction.pocketId,
                    pocketNameShot: transaction.pocketNameShot,
                    isTransfer: false,
                    status: TransactionStatus.VoidEntry,
                    voidRefId: transaction.id
                }
            })

            if(transaction.type === TransactionType.Expense){
                await tx.pocket.update({
                    where: {
                        id: transaction.pocketId
                    }, 
                    data: {
                        balance : {
                            increment : transaction.amount
                        }
                    }
                })
            } else {
                await tx.pocket.update({
                    where: {
                        id: transaction.pocketId
                    },
                    data: {
                        balance: {
                            decrement : transaction.amount
                        }
                    }
                })
            }
        })

        return {
            message: 'Transaction voided successfully',
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
