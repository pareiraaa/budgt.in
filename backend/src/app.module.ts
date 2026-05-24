import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { TransactionsModule } from './transactions/transactions.module';
import { GoalsModule } from './goals/goals.module';
import { SummaryModule } from './summary/summary.module';
import { PocketsModule } from './pockets/pockets.module';

@Module({
  imports: [PrismaModule, AuthModule, TransactionsModule, GoalsModule, SummaryModule, PocketsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
