import { Module } from '@nestjs/common';
import { DemoController } from './demo/demo.controller';
import { DemoService } from './demo/demo.service';

@Module({
  controllers: [DemoController],
  providers: [DemoService],
})
export class AppModule {}
