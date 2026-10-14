import { IsIn, IsInt, IsNotEmpty, IsString, Max, Min } from 'class-validator';

const NETWORKS = ['MTN Mobile Money', 'Moov Money', 'Celtiis Cash'] as const;

export class RechargeQuoteDto {
  @IsIn(NETWORKS)
  network!: (typeof NETWORKS)[number];

  @IsInt()
  @Min(100)
  @Max(1_000_000)
  amountXof!: number;
}

export class CreateRechargeDto extends RechargeQuoteDto {
  @IsString()
  @IsNotEmpty()
  idempotencyKey!: string;
}
