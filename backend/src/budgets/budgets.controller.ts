import { Body, Controller, Delete, Get, Param, Post, Put, Request, UseGuards} from '@nestjs/common';
import { BudgetsService } from './budgets.service';
import { CreateBudgetDto } from './dto/create-budget.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { UpdateBudgetDto } from './dto/update-budget.dto';

@UseGuards(JwtAuthGuard) // Add appropriate guards for authentication/authorization
@Controller('budgets')
export class BudgetsController {
    constructor(private budgetsService: BudgetsService) {}

    @Post()
    async createBudgets(@Request() req, @Body() dto: CreateBudgetDto) {
        const userId = req.user.id;
        return this.budgetsService.createBudget(userId, dto);
    }

    @Get()
    async getBudgets(@Request() req) {
        const userId = req.user.id;
        return this.budgetsService.getBudgets(userId);
    }

    @Get(':id')
    async getBudgetById(@Request() req, @Param('id') id: string) {
        const userId = req.user.id;
        return this.budgetsService.getBudgetById(userId, +id);
    }

    @Put(':id')
    async updateBudget(@Request() req, @Param('id') id: string, @Body() dto: UpdateBudgetDto) {
        const userId = req.user.id;
        return this.budgetsService.updateBudget(+id, userId, dto);
    }
    
    @Delete(':id')
    async deleteBudget(@Request() req, @Param('id') id: string) {
        const userId = req.user.id;
        return this.budgetsService.deleteBudget(+id, userId);
    }
}
