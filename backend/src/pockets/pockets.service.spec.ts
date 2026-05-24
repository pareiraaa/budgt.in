import { Test, TestingModule } from '@nestjs/testing';
import { PocketsService } from './pockets.service';

describe('PocketsService', () => {
  let service: PocketsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PocketsService],
    }).compile();

    service = module.get<PocketsService>(PocketsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
