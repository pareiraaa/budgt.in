import { Injectable } from '@nestjs/common';
import { TransactionType } from '@prisma/client';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class SummaryService {
    constructor(private prisma: PrismaService) {}

    //get monthly summary
    async getMonthlySummary(userId: number, month: number, year: number) {
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0, 23, 59, 59);
        
        const transactions = await this.prisma.transaction.findMany({
            where: {
                userId,
                date: {
                    gte: startDate,
                    lte: endDate,
                },
            },
        });

        //calculation
        const totalIncome = transactions
            .filter(t => t.type === TransactionType.Income)
            .reduce((sum, t) => sum + t.amount, 0);

        const totalExpense = transactions
            .filter(t => t.type === TransactionType.Expense)
            .reduce((sum, t) => sum + t.amount, 0);

        const netSavings = totalIncome - totalExpense;
        
        const budget = await this.prisma.budget.findMany({
            where: {
                userId,
                month,
                year,
            },
            include: {category: true},
        });

        const budgetWithSpent = budget.map(b => {
            const spent = transactions
                .filter(t => t.categoryId === b.categoryId && t.type === TransactionType.Expense)
                .reduce((sum, t) => sum + t.amount, 0);
            return {
                id: b.id,
                categoryId: b.categoryId,
                categoryName: b.category.categoryName,
                amount: b.amount,
                spent,
                remaining: b.amount - spent,
            };
        });

        const goals = await this.prisma.goal.findMany({
            where: {
                userId,
            },
        });

        const goalsWithProgress = goals.map(g => {
            const progress = g.currentAmount / g.targetAmount * 100;
            return {
                id: g.id,
                goalName: g.goalName,
                targetAmount: g.targetAmount,
                currentAmount: g.currentAmount,
                deadline: g.deadline,
                progress: Math.min(progress, 100),
            };
        });

        return {
            totalIncome,
            totalExpense,
            netSavings,
            budget: budgetWithSpent,
            goals: goalsWithProgress,
        };

    }

    
}
