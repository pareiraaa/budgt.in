import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateBudgetDto } from './dto/create-budget.dto';
import { TransactionType } from '@prisma/client';
import { UpdateBudgetDto } from './dto/update-budget.dto';

@Injectable()
export class BudgetsService {
    constructor(private prisma: PrismaService) {}

    async createBudget(userId: number, dto: CreateBudgetDto) {
        const budget = await this.prisma.budget.create({
            data: {
                userId: userId,
                amount: dto.amount,
                categoryId: dto.categoryId,
                month: dto.month,
                year: dto.year,
            },
        });
        return {
            id: budget.id,
            amount: budget.amount,
            categoryId: budget.categoryId,
            month: budget.month,
            year: budget.year,
        };
    }

    async getBudgets(userId: number) {
        const budgets = await this.prisma.budget.findMany({
            where: {
                userId: userId,
            },
        });
        return budgets.map((budget) => ({
            id: budget.id,
            amount: budget.amount,
            categoryId: budget.categoryId,
            month: budget.month,
            year: budget.year,
        }));
    }

    async getBudgetById(userId: number, budgetId: number) {
        const budget = await this.validateBudget(userId, budgetId);

        const spentAmount = await this.prisma.transaction.aggregate({
            where: {
                userId: userId,
                categoryId: budget.categoryId,
                type: TransactionType.Expense,
                date: {
                    gte: new Date(budget.year, budget.month - 1, 1),
                    lt: new Date(budget.year, budget.month, 1),
                },
            },
            _sum: {
                amount: true,
            },
        });

        const totalSpent = spentAmount._sum.amount || 0;
        const remainingAmount = budget.amount - totalSpent;
        return {
            id: budget.id,
            amount: budget.amount,
            categoryId: budget.categoryId,
            month: budget.month,
            year: budget.year,
            spentAmount: totalSpent,
            remainingAmount: remainingAmount,
        };
    }   

    async updateBudget(id: number, userId: number, dto: UpdateBudgetDto) {
        const budget = await this.validateBudget(userId, id);

        await this.prisma.budget.update({
            where: {
                id: budget.id,
            },
            data: {
                amount: dto.amount,
                categoryId: dto.categoryId,
                month: dto.month,
                year: dto.year,
            },
        });

        return {
            "message": "Budget updated successfully",
        };
    }

    async deleteBudget(id: number, userId: number) {
        const budget = await this.validateBudget(userId, id);

        await this.prisma.budget.delete({
            where: {
                id: budget.id,
            },
        }); 
        return {
            "message": "Budget deleted successfully",
        };
    }

    private async validateBudget(userId: number, budgetId: number) {
        const budget = await this.prisma.budget.findFirst({
            where: {
                id: budgetId,
                userId: userId,
            },
        });
        
        if (!budget) {
            throw new NotFoundException('Budget not found');
        }
        return budget;
    }
}
