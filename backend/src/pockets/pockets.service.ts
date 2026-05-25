import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreatePocketDto } from './dto/create-pocket.dto';
import { UpdatePocketDto } from './dto/update-pocket.dto';
import { TransferDto } from './dto/transfer.dto';
import { PocketType, TransactionType } from '@prisma/client';

@Injectable()
export class PocketsService {
    constructor(private prisma: PrismaService) {}

    async createPocket(userId: number, dto: CreatePocketDto) {
        const pocket = await this.prisma.pocket.create({
            data: {
                pocketName: dto.name,
                pocketType: dto.pocketType,
                targetAmount: dto.targetAmount,
                deadline: dto.deadline ? new Date(dto.deadline) : undefined,
                userId: userId
            }
        });
        return {
            id: pocket.id,
            pocketName: pocket.pocketName,
            pocketType: pocket.pocketType,
            targetAmount: pocket.targetAmount,
            deadline: pocket.deadline,
            createdAt: pocket.createdAt,
        };
    }

    async getPockets(userId: number) {
        const pockets = await this.prisma.pocket.findMany({
            where: { 
                userId: userId ,
                deletedAt: null
            },
            orderBy: { createdAt: 'asc' },
        });
        return pockets.map(pocket => ({
            id: pocket.id,
            pocketName: pocket.pocketName,
            pocketType: pocket.pocketType,
            balance: pocket.balance,
            targetAmount: pocket.targetAmount,
            deadline: pocket.deadline,
            createdAt: pocket.createdAt,
        }));
    }

    async getPocketById(id: number, userId: number) {
        const pocket = await this.validatePocket(id, userId);

        return {
            id: pocket.id,
            pocketName: pocket.pocketName,
            pocketType: pocket.pocketType,
            balance: pocket.balance,
            targetAmount: pocket.targetAmount,
            deadline: pocket.deadline,
            createdAt: pocket.createdAt,
        };
    }

    private async validatePocket(id: number, userId: number) {
        const pocket = await this.prisma.pocket.findFirst({
            where: { 
                id: id,
                userId: userId,
                deletedAt: null
            },
        });
        if (!pocket) {
            throw new NotFoundException('Pocket not found');
        }
        return pocket;
    }

    async updatePocket(id: number, userId: number, dto: UpdatePocketDto) {
        await this.validatePocket(id, userId);

        await this.prisma.pocket.update({
            where: {
                id: id,
            },
            data: {
                pocketName: dto.name,
                targetAmount: dto.targetAmount,
                deadline: dto.deadline ? new Date(dto.deadline) : undefined,
            },
        });

        return {
            message: 'Pocket updated successfully',
        };
    }

    async transferToPocket(userId: number, dto: TransferDto) {
        const fromPocket = await this.validatePocket(dto.fromPocketId, userId);
        const toPocket = await this.validatePocket(dto.toPocketId, userId);

        if(fromPocket.id === toPocket.id) {
            throw new BadRequestException('Source and destination pockets cannot be the same');
        }

        if(dto.amount <= 0) {
            throw new BadRequestException('Invalid transfer amount');
        }

        if (fromPocket.balance < dto.amount) {
            throw new BadRequestException('Insufficient balance in the source pocket');
        }

        await this.prisma.$transaction(async (tx) => {
            await tx.transaction.create({
                data: {
                    amount: dto.amount,
                    type: TransactionType.Expense,
                    note: `Transfer to ${toPocket.pocketName}`,
                    date: new Date(),
                    userId: userId,
                    pocketId: fromPocket.id,
                    pocketNameShot: fromPocket.pocketName,
                    isTransfer: true,
                }
            });

            await tx.transaction.create({
                data: {
                    amount: dto.amount,
                    type: TransactionType.Income,
                    note: `Transfer from ${fromPocket.pocketName}`,
                    date: new Date(),
                    userId: userId,
                    pocketId: toPocket.id,
                    pocketNameShot: toPocket.pocketName,
                    isTransfer: true,
                }
            });

            await tx.pocket.update({
                where: { id: fromPocket.id },
                data: { balance: {
                    decrement: dto.amount
                } },
            });

            await tx.pocket.update({
                where: { id: toPocket.id },
                data: { balance: {
                    increment: dto.amount
                } },
            });
        });

        return {
            message: 'Transfer successful',
        };
    }

    async deletePocket(id: number, userId: number) {
        const pocket = await this.validatePocket(id, userId);

        if(pocket.pocketType === PocketType.Main) {
            throw new BadRequestException('Cannot delete main pocket');
        }

        const mainPocket = await this.prisma.pocket.findFirst({
            where: {
                userId: userId,
                pocketType: PocketType.Main,
                deletedAt: null
            },
        });

        if (!mainPocket) {
            throw new NotFoundException('Main pocket not found');
        }

        await this.prisma.$transaction(async (tx) => {
            if(pocket.balance > 0) {
                await tx.transaction.create({
                    data: {
                        amount: pocket.balance,
                        type: TransactionType.Income,
                        note: `Transfer from deleted pocket ${pocket.pocketName}`,
                        date: new Date(),
                        userId: userId,
                        pocketId: mainPocket.id,
                        pocketNameShot: mainPocket.pocketName,
                        isTransfer: true,
                    }
                });

                await tx.transaction.create({
                    data: {
                        amount: pocket.balance,
                        type: TransactionType.Expense,
                        note: `Transfer to main pocket`,
                        date: new Date(),
                        userId: userId,
                        pocketId: pocket.id,
                        pocketNameShot: pocket.pocketName,
                        isTransfer: true,
                    }
                });

                await tx.pocket.update({
                    where: { id: mainPocket.id },
                    data: { balance: {
                        increment: pocket.balance
                    } },
                });

                await tx.pocket.update({
                    where: { id: pocket.id },
                    data: { balance: 0 },
                });
            }

            await tx.pocket.update({
                where: {
                    id: id,
                },
                data: {
                    deletedAt: new Date(),
                },
            });
        });

        return {
            message: 'Pocket deleted successfully',
        };
    }
}