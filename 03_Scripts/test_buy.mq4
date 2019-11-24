//+------------------------------------------------------------------+
//|                                                     test_buy.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_confirm // 実行前に確認ウィンドウ表示
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int ticket; //ticket number
   ticket = OrderSend(_Symbol, OP_BUY, 0.01, Ask, 3, 0, 0); // new buy order
   MessageBox("Ticket Number="+ticket);
  }
//+------------------------------------------------------------------+
