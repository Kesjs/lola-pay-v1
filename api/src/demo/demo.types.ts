export type TransactionStatus =
  | 'pending'
  | 'processing'
  | 'succeeded'
  | 'failed';

export type TransactionType = 'recharge';

export interface DemoTransaction {
  id: string;
  userId: string;
  type: TransactionType;
  network: string;
  amountXof: number;
  feeXof: number;
  status: TransactionStatus;
  idempotencyKey: string;
  reference: string;
  createdAt: string;
  updatedAt: string;
  failureReason?: string;
}

export interface LedgerEntry {
  id: string;
  transactionId: string;
  account: 'user_wallet' | 'partner_clearing';
  direction: 'debit' | 'credit';
  amountXof: number;
  createdAt: string;
}

export interface DemoState {
  user: {
    id: string;
    phone: string;
    status: 'sandbox';
  };
  walletBalanceXof: number;
  transactions: DemoTransaction[];
  ledgerEntries: LedgerEntry[];
}
