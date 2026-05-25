import { Injectable } from '@nestjs/common';
import { PocketType, TransactionStatus, TransactionType } from '@prisma/client';
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
                isTransfer: false,
                status: TransactionStatus.Active
            },
        });

        const totalIncome = transactions
        .filter(t => t.type === TransactionType.Income)
        .reduce((sum,t) => sum + t.amount, 0)

        const totalExpense = transactions
        .filter(t => t.type === TransactionType.Expense)
        .reduce((sum,t) => sum + t.amount, 0)

        const netSavings = totalIncome - totalExpense;

        const goals = await this.prisma.pocket.findMany({
            where: {
                userId,
                pocketType: PocketType.Goal,
                deletedAt: null
            },
        });

        const goalsWithProgress = goals.map(g => {
            const target = g.targetAmount ?? 0;
            const progress =  target > 0 ? (g.balance/target) * 100 : 0;
            return {
                id: g.id,
                goalName: g.pocketName,
                targetAmount: g.targetAmount,
                currentAmount: g.balance,
                deadline: g.deadline,
                progress: Math.min(progress, 100),
            };
        });

        const incomeTransaction = transactions.filter(t => t.type === TransactionType.Income);

        const incomeBySource: Record<string, number> = {};
        for(const t of incomeTransaction){
            const source = t.incomeSource ?? 'Other';
            incomeBySource[source] = (incomeBySource[source] ?? 0) + t.amount;
        }

        const incomePie = Object.entries(incomeBySource).map(([source, amount]) => ({
            source,
            amount,
            percentage: totalIncome > 0 ? (amount/totalIncome) * 100 : 0
        }))

        const expenseTransaction = transactions.filter(t => t.type === TransactionType.Expense);

        const expenseByPocket: Record<string, number> = {};
        for(const t of expenseTransaction){
            const source = t.pocketNameShot ?? 'Other';
            expenseByPocket[source] = (expenseByPocket[source] ?? 0) + t.amount;
        }

        const expensePie = Object.entries(expenseByPocket).map(([pocketName, amount]) => ({
            pocketName,
            amount,
            percentage: totalExpense > 0 ? (amount/totalExpense) * 100 : 0
        }))

        const alocationTransaction = await this.prisma.transaction.findMany({
            where:{
                userId,
                date: { gte: startDate, lte: endDate },
                isTransfer: true,                    
                type: TransactionType.Income,        
                status: TransactionStatus.Active,
                pocket: {
                    pocketType: { not: PocketType.Main }, 
                    deletedAt: null,  
                },
            }
        })

        const goalPocketIds = await this.prisma.pocket.findMany({
            where: { userId, pocketType: PocketType.Goal, deletedAt: null },
            select: { id: true }
        }).then(res => new Set(res.map(p => p.id)));

        const alocationByPocket: Record<string, number> = {}
        for(const t of alocationTransaction){
            const isGoal = goalPocketIds.has(t.pocketId);
            const name = isGoal ? 'Tabungan' : t.pocketNameShot;
            alocationByPocket[name] = (alocationByPocket[name] ?? 0) + t.amount;
        }

        const totalAlocated = Object.values(alocationByPocket).reduce((sum,v) => sum + v, 0)

        const alocationPie = Object.entries(alocationByPocket).map(([pocketName, amount]) => ({
            pocketName,
            amount,
            percentage: totalIncome > 0 ? (amount/totalIncome) * 100 : 0
        }))

        const unalocated = Math.max(0, totalIncome-totalAlocated)

        return {
            totalIncome,
            totalExpense,
            netSavings,
            incomePie,
            alocationPie: alocationPie,
            unalocated: unalocated,
            expensePie,
            goals: goalsWithProgress,
        };



    }

    
}
