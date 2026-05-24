export class SettleGoalDto {
  usedAmount!: number;          // uang yang beneran kepake (jadi expense)
  coverFromPocketId?: number;   // kalau kepake > saldo goal, ambil dari sini
}