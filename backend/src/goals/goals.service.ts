import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateGoalDto } from './dto/create-goals.dto';
import { UpdateGoalDto } from './dto/update-goals.dto';
import { TopUpGoalsDto } from './dto/topup-goals.dto';

@Injectable()
export class GoalsService {
    constructor(private prisma: PrismaService) {}

    async createGoal(userId: number, dto: CreateGoalDto) {
        const goal = await this.prisma.goal.create({
            data: {
                userId,
                goalName: dto.goalName,
                targetAmount: dto.targetAmount,
                currentAmount: 0,
                deadline: new Date(dto.deadline),     
            }
        });

        return {
            id: goal.id,
            goalName: goal.goalName,
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            deadline: goal.deadline,
        };
    }

    async getGoals(userId: number) {
        const goals = await this.prisma.goal.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
        });
        
        return goals.map(goal => ({
            id: goal.id,
            goalName: goal.goalName,
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            deadline: goal.deadline,
        }));
    }

    async getGoalById(userId: number, goalId: number) {
        const goal = await this.validateGoals(userId, goalId);

        return {
            id: goal.id,    
            goalName: goal.goalName,
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            deadline: goal.deadline,
        };
    }

    async updateGoal(userId: number, goalId: number, dto: UpdateGoalDto) {
        const goal = await this.validateGoals(userId, goalId);
        
        await this.prisma.goal.update({
            where: { id: goalId },
            data: {
                goalName: dto.goalName,
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

        const newAmount = goal.currentAmount + dto.amount;
        const message = newAmount >= goal.targetAmount ? 'Congratulations! Goal achieved!' : 'Goal top-up successful';

        await this.prisma.goal.update({
            where: { id: goalId },
            data: {
                currentAmount: newAmount,
            },
        });

        return {
            message: message,
               data: {
                id: goal.id,
                goalName: goal.goalName,
                targetAmount: goal.targetAmount,
                currentAmount: newAmount,
                deadline: goal.deadline,
            }
        };
    }

    async deleteGoal(userId: number, goalId: number) {
        await this.validateGoals(userId, goalId);
        
        await this.prisma.goal.delete({
            where: { id: goalId },
        });

        return { 
            message: 'Goal deleted successfully' 
        };
    }

    private async validateGoals(userId: number, goalId: number) {
        const goal = await this.prisma.goal.findFirst({
            where: { 
                id: goalId,
                userId: userId,
            },
        });
        
        if (!goal) {
            throw new NotFoundException('Goal not found or access denied');
        }

        return goal;
    }
}