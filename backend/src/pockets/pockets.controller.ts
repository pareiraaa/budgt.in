import { Body, Controller, Delete, Get, Param, Post, Put, Request, UseGuards} from '@nestjs/common';
import { PocketsService } from './pockets.service';
import { CreatePocketDto } from './dto/create-pocket.dto';
import { UpdatePocketDto } from './dto/update-pocket.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { TransferDto } from './dto/transfer.dto';

@UseGuards(JwtAuthGuard) // Add your authentication guard here
@Controller('pockets')
export class PocketsController {
    constructor(private pocketsService: PocketsService) {}

    @Post()
    async createPocket(@Body() dto: CreatePocketDto, @Request() req) {
        const userId = req.user.id;
        return this.pocketsService.createPocket(userId, dto);
    }

    @Get()
    async getPockets(@Request() req) {
        const userId = req.user.id;
        return this.pocketsService.getPockets(userId);
     }

    @Get(':id')
    async getPocketById(@Request() req, @Param('id') id: number) {
        const userId = req.user.id;
        return this.pocketsService.getPocketById(+id, userId);
    }
    
    @Put(':id')
    async updatePocket(@Request() req, @Param('id') id: number, @Body() dto: UpdatePocketDto) {
        const userId = req.user.id;
        return this.pocketsService.updatePocket(+id, userId, dto);
    }

    @Post('transfer')
    async transferToPocket(@Request() req, @Body() dto: TransferDto) {
        const userId = req.user.id;
        return this.pocketsService.transferToPocket(userId, dto);
    }

    @Delete(':id')
    async deletePocket(@Request() req, @Param('id') id: number) {
        const userId = req.user.id;
        return this.pocketsService.deletePocket(+id, userId);
    }

}
