import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { CategoriesModule } from './categories/categories.module';
import { TransactionsModule } from './transactions/transactions.module';
import { BudgetsModule } from './budgets/budgets.module';
import { GoalsModule } from './goals/goals.module';
import { SummaryModule } from './summary/summary.module';

@Module({
  imports: [PrismaModule, AuthModule, CategoriesModule, TransactionsModule, BudgetsModule, GoalsModule, SummaryModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
