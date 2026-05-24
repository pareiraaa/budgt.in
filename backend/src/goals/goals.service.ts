import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateGoalDto } from './dto/create-goals.dto';
import { UpdateGoalDto } from './dto/update-goals.dto';
import { TopUpGoalsDto } from './dto/topup-goals.dto';
import { PocketType, TransactionType } from '@prisma/client';
import { PocketsService } from 'src/pockets/pockets.service';
import { SettleGoalDto } from './dto/settlement.dto';

@Injectable()
export class GoalsService {
    constructor(private prisma: PrismaService, private pocketService: PocketsService) {}

    async createGoal(userId: number, dto: CreateGoalDto) {
        const goal = await this.prisma.pocket.create({
            data: {
                userId,
                pocketName: dto.goalName,
                pocketType: PocketType.Goal,
                targetAmount: dto.targetAmount,
                deadline: new Date(dto.deadline),     
            }
        });

        return {
            id: goal.id,
            goalName: goal.pocketName,
            targetAmount: goal.targetAmount,
            currentAmount: goal.balance,
            deadline: goal.deadline,
        };
    }

    async getGoals(userId: number) {
        const goals = await this.prisma.pocket.findMany({
            where: { 
                userId: userId,
                pocketType: PocketType.Goal,
                deletedAt: null
            },
            orderBy: { createdAt: 'desc' },
        });
        
        return goals.map(goal => ({
            id: goal.id,
            goalName: goal.pocketName,
            targetAmount: goal.targetAmount,
            currentAmount: goal.balance,
            deadline: goal.deadline,
        }));
    }

    async getGoalById(userId: number, goalId: number) {
        const goal = await this.validateGoals(userId, goalId);
        const recommendation = this.calculateRecomendation(goal);

        return {
            id: goal.id,    
            goalName: goal.pocketName,
            targetAmount: goal.targetAmount,
            currentAmount: goal.balance,
            deadline: goal.deadline,
            recommendation
        };
    }

    async updateGoal(userId: number, goalId: number, dto: UpdateGoalDto) {
        const goal = await this.validateGoals(userId, goalId);
        
        await this.prisma.pocket.update({
            where: { id: goalId },
            data: {
                pocketName: dto.goalName,
                targetAmount: dto.targetAmount,
                deadline: dto.deadline ? new Date(dto.deadline) : goal.deadline,
            },
        });

        return {
            message: 'Goal updated successfully',
        };
    }

    async topUpGoal(userId: number, goalId: number, dto: TopUpGoalsDto) {
        const goal = await this.validateGoals(userId, goalId);

        const mainPocket = await this.prisma.pocket.findFirst({
            where: {
                userId: userId,
                pocketType: PocketType.Main,
                deletedAt: null
            }
        })

        if(!mainPocket){
            throw new NotFoundException('Main pocket not found')
        }

        await this.pocketService.transferToPocket(userId, {
            fromPocketId: mainPocket.id,
            toPocketId: goalId,
            amount: dto.amount
        })

        const updatedGoal = await this.validateGoals(userId, goalId)

        const message = updatedGoal.balance >= (updatedGoal.targetAmount ?? 0) ? 'Congratulation, goal achieved' : 'Goal top up successful'

        return {
            message: message,
            data: {
                id: updatedGoal.id,
                goalName: updatedGoal.pocketName,
                targetAmount: updatedGoal.targetAmount,
                currentAmount: updatedGoal.balance,
                deadline: goal.deadline,
            }
        };
    }

    async deleteGoal(userId: number, goalId: number) {
        await this.validateGoals(userId, goalId);

        return this.pocketService.deletePocket(goalId, userId);
    }

    async settleGoal(userId: number, goalId: number, dto: SettleGoalDto){
        const goal = await this.validateGoals(userId, goalId)

        const rec = this.calculateRecomendation(goal)

        if(rec.status !== 'Achieved' && rec.status !== 'Overdue'){
            throw new BadRequestException('Goal not achieved or overdue');
        }

        if(dto.usedAmount < 0){
            throw new BadRequestException('Used amount not valid')
        }

        const mainPocket = await this.prisma.pocket.findFirst({
            where:{
                userId,
                pocketType: PocketType.Main,
                deletedAt: null
            }
        })

        if(!mainPocket){
            throw new NotFoundException('Main pocket not found')
        }

        const goalBalance = goal.balance
        const shortage = dto.usedAmount - goalBalance

        let coverPocket: {
            id: number,
            pocketName: string,
            balance: number
        } | null = null

        if(shortage > 0){
            if(!dto.coverFromPocketId){
                throw new BadRequestException('Insufficient balance. Choose cover pocket')
            }

            coverPocket = await this.prisma.pocket.findFirst({
                where:{
                    id: dto.coverFromPocketId,
                    userId,
                    deletedAt: null
                }
            })

            if(!coverPocket){
                throw new NotFoundException('Cover pocket not found')
            }

            if(coverPocket.balance < shortage){
                throw new BadRequestException('Insufficient cover balance');
            }
        }

        await this.prisma.$transaction(async (tx) => {
            if(shortage>0 && coverPocket){
                await tx.transaction.create({
                    data:{
                        amount: shortage,
                        type: TransactionType.Expense,
                        note: `Talangin settlement ${goal.pocketName}`,
                        date: new Date(),
                        userId,
                        pocketId: coverPocket.id,
                        pocketNameShot: coverPocket.pocketName,
                        isTransfer: true,
                    }
                })

                await tx.transaction.create({
                    data: {
                        amount: shortage,
                        type: TransactionType.Income,
                        note: `Talangan dari ${coverPocket.pocketName}`,
                        date: new Date(),
                        userId,
                        pocketId: goalId,
                        pocketNameShot: goal.pocketName,
                        isTransfer: true,
                    }
                })

                await tx.pocket.update({
                    where: {
                        id: coverPocket.id
                    },
                    data: {
                        balance: {
                            decrement: shortage
                        }
                    }
                })

                await tx.pocket.update({
                    where: {
                        id: goalId
                    },
                    data: {
                        balance: {
                            increment: shortage
                        }
                    }
                })
            }

            await tx.transaction.create({
                data:{
                    amount: dto.usedAmount,
                    type: TransactionType.Expense,
                    note: `Settlement goal ${goal.pocketName}`,
                    date: new Date(),
                    userId,
                    pocketId: goalId,
                    pocketNameShot: goal.pocketName,
                    isTransfer: false,
                }
            })

            await tx.pocket.update({
                where: {
                    id: goalId
                },
                data: {
                    balance: {
                        decrement: dto.usedAmount
                    }
                }
            })

            const leftover = goalBalance - dto.usedAmount;
            if(leftover > 0){
                await tx.transaction.create({
                    data: {
                        amount: leftover,
                        type: TransactionType.Expense,
                        note: `Sisa settlement ke Main`,
                        date: new Date(),
                        userId,
                        pocketId: goalId,
                        pocketNameShot: goal.pocketName,
                        isTransfer: true,
                    }
                })

                await tx.transaction.create({
                    data: {
                        amount: leftover,
                        type: TransactionType.Income,
                        note: `Sisa settlement dari ${goal.pocketName}`,
                        date: new Date(),
                        userId,
                        pocketId: mainPocket.id,
                        pocketNameShot: mainPocket.pocketName,
                        isTransfer: true,
                    }
                })

                await tx.pocket.update({
                    where: {
                        id: goalId
                    },
                    data: {
                        balance: {
                            decrement: leftover
                        }
                    }
                })

                await tx.pocket.update({
                    where: {
                        id: mainPocket.id
                    },
                    data: {
                        balance: {
                            increment: leftover
                        }
                    }
                })
            }

            await tx.pocket.update({
                where: {
                    id: goalId
                },
                data: {
                    deletedAt: new Date()
                }
            })

        })

        return {
            message: 'Goal settled succesfully'
        }
    }

    private async validateGoals(userId: number, goalId: number) {
        const goal = await this.prisma.pocket.findFirst({
            where: { 
                id: goalId,
                userId: userId,
                pocketType: PocketType.Goal,
                deletedAt: null
            },
        });
        
        if (!goal) {
            throw new NotFoundException('Goal not found or access denied');
        }

        return goal;
    }

    private calculateRecomendation(goal: {
        balance: number;
        targetAmount: number | null;
        deadline: Date | null;
    }) {
        const target = goal.targetAmount ?? 0
        const remaining = target - goal.balance

        if(remaining <= 0){
            return {
                status: 'Achieved',
                monthlyRecommendation: 0,
                remaining: 0
            }
        }

        if(!goal.deadline){
            return {
                status: 'NoDeadline',
                monthlyRecommendation: 0,
                remaining
            }
        }

        const now = new Date();
        const deadline = new Date(goal.deadline)

        if(deadline < now){
            return {
                status: 'Overdue',
                monthlyRecommendation: 0,
                remaining
            }
        }

        const monthleft = this.monthsBetween(now, deadline)

        if(monthleft <= 0){
            return {
                status: 'Due this month',
                monthlyRecommendation: remaining,
                remaining
            }
        }

        //normal
        const monthlyRecommendation = Math.ceil(remaining/monthleft)
        return {
            status: 'OnTrack',
            monthlyRecommendation,
            remaining
        }


    }

    private monthsBetween(from: Date, to: Date): number {
        const years = to.getFullYear() - from.getFullYear();
        const months = to.getMonth() - from.getMonth();
        return years * 12 + months;
    }
}