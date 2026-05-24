import { Module } from '@nestjs/common';
import { GoalsService } from './goals.service';
import { GoalsController } from './goals.controller';
import { PocketsModule } from 'src/pockets/pockets.module';

@Module({
  providers: [GoalsService],
  controllers: [GoalsController],
  imports: [PocketsModule]
})
export class GoalsModule {}
