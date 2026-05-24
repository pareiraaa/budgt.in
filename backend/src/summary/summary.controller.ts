import { Controller, Get, Query, Request, UseGuards} from '@nestjs/common';
import { SummaryService } from './summary.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('summary')
export class SummaryController {
    constructor(private summaryService: SummaryService) {}

    @Get()
    async getMonthlySummary(@Request() req, @Query('month') month: number, @Query('year') year: number) {
        const userId = req.user.id;
        return this.summaryService.getMonthlySummary(userId, +month, +year);
    }
}
