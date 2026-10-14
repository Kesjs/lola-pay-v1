import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { CreateRechargeDto, RechargeQuoteDto } from './demo.dto';
import { DemoState, DemoTransaction, LedgerEntry } from './demo.types';

const now = () => new Date().toISOString();
const statePath = join(process.cwd(), '.data', 'sandbox-state.json');

function createInitialState(): DemoState {
  return {
    user: {
      id: 'sandbox-user-1',
      phone: '+229 01 23 45 67 89',
      status: 'sandbox',
    },
    walletBalanceXof: 0,
    transactions: [],
    ledgerEntries: [],
  };
}

function loadState(): DemoState {
  if (!existsSync(statePath)) return createInitialState();
  try {
    return JSON.parse(readFileSync(statePath, 'utf8')) as DemoState;
  } catch {
    return createInitialState();
  }
}

function saveState(state: DemoState) {
  mkdirSync(join(process.cwd(), '.data'), { recursive: true });
  writeFileSync(statePath, JSON.stringify(state, null, 2), 'utf8');
}

@Injectable()
export class DemoService {
  private readonly state: DemoState = loadState();

  getHealth() {
    return {
      service: 'lola-pay-api',
      environment: 'sandbox',
      financialIntegrations: 'disabled',
      timestamp: now(),
    };
  }

  getWallet() {
    return {
      environment: 'sandbox',
      user: this.state.user,
      balanceXof: this.state.walletBalanceXof,
      availableXof: this.state.walletBalanceXof,
      reservedXof: 0,
    };
  }

  getTransactions() {
    return [...this.state.transactions].sort(
      (a, b) => b.createdAt.localeCompare(a.createdAt),
    );
  }

  getOverview() {
    const transactions = this.getTransactions();
    const succeeded = transactions.filter((item) => item.status === 'succeeded');
    const pending = transactions.filter(
      (item) => item.status === 'pending' || item.status === 'processing',
    );

    return {
      environment: 'sandbox',
      generatedAt: now(),
      users: 1,
      walletBalanceXof: this.state.walletBalanceXof,
      volumeXof: succeeded.reduce((total, item) => total + item.amountXof, 0),
      transactionCount: transactions.length,
      pendingCount: pending.length,
      failedCount: transactions.filter((item) => item.status === 'failed').length,
      ledgerEntries: this.state.ledgerEntries.length,
      ledgerBalanced: this.isLedgerBalanced(),
      transactions: transactions.slice(0, 8),
    };
  }

  getLedger() {
    return {
      environment: 'sandbox',
      balanced: this.isLedgerBalanced(),
      entries: [...this.state.ledgerEntries],
    };
  }

  quoteRecharge(input: RechargeQuoteDto) {
    return {
      environment: 'sandbox',
      network: input.network,
      amountXof: input.amountXof,
      feeXof: 0,
      totalXof: input.amountXof,
      creditedXof: input.amountXof,
      expiresAt: new Date(Date.now() + 5 * 60_000).toISOString(),
    };
  }

  createRecharge(input: CreateRechargeDto) {
    const existing = this.state.transactions.find(
      (transaction) => transaction.idempotencyKey === input.idempotencyKey,
    );
    if (existing) return existing;

    const timestamp = now();
    const transaction: DemoTransaction = {
      id: randomUUID(),
      userId: this.state.user.id,
      type: 'recharge',
      network: input.network,
      amountXof: input.amountXof,
      feeXof: 0,
      status: 'pending',
      idempotencyKey: input.idempotencyKey,
      reference: `LP-SBX-${Date.now().toString(36).toUpperCase()}`,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    this.state.transactions.push(transaction);
    saveState(this.state);
    this.processRecharge(transaction.id);
    return transaction;
  }

  getTransaction(id: string) {
    const transaction = this.state.transactions.find((item) => item.id === id);
    if (!transaction) throw new NotFoundException('Transaction introuvable');
    return transaction;
  }

  private processRecharge(transactionId: string) {
    const transaction = this.getTransaction(transactionId);
    transaction.status = 'processing';
    transaction.updatedAt = now();
    saveState(this.state);

    setTimeout(() => {
      const current = this.getTransaction(transactionId);
      if (current.status !== 'processing') return;

      current.status = 'succeeded';
      current.updatedAt = now();
      this.state.walletBalanceXof += current.amountXof;
      this.postBalancedJournal(current);
      saveState(this.state);
    }, 900);
  }

  private postBalancedJournal(transaction: DemoTransaction) {
    const createdAt = now();
    const entries: LedgerEntry[] = [
      {
        id: randomUUID(),
        transactionId: transaction.id,
        account: 'partner_clearing',
        direction: 'debit',
        amountXof: transaction.amountXof,
        createdAt,
      },
      {
        id: randomUUID(),
        transactionId: transaction.id,
        account: 'user_wallet',
        direction: 'credit',
        amountXof: transaction.amountXof,
        createdAt,
      },
    ];
    this.state.ledgerEntries.push(...entries);
  }

  private isLedgerBalanced() {
    const totals = this.state.ledgerEntries.reduce(
      (summary, entry) => {
        summary[entry.direction] += entry.amountXof;
        return summary;
      },
      { debit: 0, credit: 0 },
    );
    return totals.debit === totals.credit;
  }
}
