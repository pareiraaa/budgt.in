import { Body, Controller, Delete, Get, Param, Post, Put, Request, UseGuards} from '@nestjs/common';
import { GoalsService } from './goals.service';
import { CreateGoalDto } from './dto/create-goals.dto';
import { UpdateGoalDto } from './dto/update-goals.dto';
import { TopUpGoalsDto } from './dto/topup-goals.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { SettleGoalDto } from './dto/settlement.dto';

@UseGuards(JwtAuthGuard) // Add your authentication guard here
@Controller('goals')
export class GoalsController {
    constructor(private goalsService: GoalsService) {}

    @Post()
    createGoal(@Request() req, @Body() dto: CreateGoalDto) {
        const userId = req.user.id;
        return this.goalsService.createGoal(userId, dto);
    }

    @Get()
    getGoals(@Request() req) {
        const userId = req.user.id;
        return this.goalsService.getGoals(userId);
    }

    @Get(':id')
    getGoalById(@Request() req, @Param('id') goalId: string) {
        const userId = req.user.id;
        return this.goalsService.getGoalById(userId, +goalId);
    }

    @Put(':id')
    updateGoal(@Request() req, @Param('id') goalId: string, @Body() dto: UpdateGoalDto) {
        const userId = req.user.id;
        return this.goalsService.updateGoal(userId, +goalId, dto);
    }

    @Post(':id/top-up')
    topUpGoal(@Request() req, @Param('id') goalId: string, @Body() dto: TopUpGoalsDto) {
        const userId = req.user.id;
        return this.goalsService.topUpGoal(userId, +goalId, dto);
    }

    @Delete(':id')
    deleteGoal(@Request() req, @Param('id') goalId: string) {
        const userId = req.user.id;
        return this.goalsService.deleteGoal(userId, +goalId);
    }

    @Post(':id/settle')
    async settleGoal(@Request() req, @Param('id') id: string, @Body() dto: SettleGoalDto) {
        return this.goalsService.settleGoal(req.user.id, +id, dto);
    }
    
}
