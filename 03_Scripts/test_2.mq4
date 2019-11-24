//+------------------------------------------------------------------+
//|                                                       test_2.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int i;
   double x1;
   string Str;
   
   i = 10;
   x1 = 1.23;
   Str = "MetaTrader4";
   
   Print("i=", i);
   Print("x1=", x1);
   Print("Str=", Str);
  }
//+------------------------------------------------------------------+
