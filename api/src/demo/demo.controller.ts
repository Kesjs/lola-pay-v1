import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CreateRechargeDto, RechargeQuoteDto } from './demo.dto';
import { DemoService } from './demo.service';

@Controller()
export class DemoController {
  constructor(private readonly demoService: DemoService) {}

  @Get('health')
  getHealth() {
    return this.demoService.getHealth();
  }

  @Get('wallet')
  getWallet() {
    return this.demoService.getWallet();
  }

  @Get('transactions')
  getTransactions() {
    return this.demoService.getTransactions();
  }

  @Get('transactions/:id')
  getTransaction(@Param('id') id: string) {
    return this.demoService.getTransaction(id);
  }

  @Post('transactions/quote')
  quoteRecharge(@Body() body: RechargeQuoteDto) {
    return this.demoService.quoteRecharge(body);
  }

  @Post('transactions/recharge')
  createRecharge(@Body() body: CreateRechargeDto) {
    return this.demoService.createRecharge(body);
  }

  @Get('admin/overview')
  getOverview() {
    return this.demoService.getOverview();
  }

  @Get('admin/ledger')
  getLedger() {
    return this.demoService.getLedger();
  }
}
