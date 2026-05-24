import { Body, Controller, Delete, Get, Param, Post, Put, Query, Request, UseGuards} from '@nestjs/common';
import { TransactionsService } from './transactions.service';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard) // Add your authentication guard here
@Controller('transactions')
export class TransactionsController {
    constructor(private transactionsService: TransactionsService) {}

    @Post()
    async createTransaction(@Body() dto: CreateTransactionDto, @Request() req) {
        const userId = req.user.id;
        return this.transactionsService.createTransaction(dto, userId);
    }

    @Get()
    async getTransactions(@Request() req, @Query('date') date?: string) {
        const userId = req.user.id;
        return this.transactionsService.getTransactions(userId, date);
    }

    @Get(':id')
    async getTransactionById(@Request() req, @Param('id') id: string) {
        const userId = req.user.id;
        return this.transactionsService.getTransactionById(+id, userId);
    }

    @Put(':id')
    async updateTransaction(@Request() req, @Param('id') id: string, @Body() dto: UpdateTransactionDto) {
        const userId = req.user.id;
        return this.transactionsService.updateTransaction(+id, userId, dto);
    }

    @Delete(':id')
    async voidTransaction(@Request() req, @Param('id') id: string) {
        const userId = req.user.id;
        return this.transactionsService.voidTransaction(+id, userId);
    }
}
