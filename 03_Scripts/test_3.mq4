//+------------------------------------------------------------------+
//|                                                       test_3.mq4 |
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
   double a=1.2, b=2.5, c;
   c = MathMax(a, b);
   Print("c=", c); 
  }
//+------------------------------------------------------------------+
