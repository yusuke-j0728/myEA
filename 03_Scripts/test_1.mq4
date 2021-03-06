//+------------------------------------------------------------------+
//|                                                     test_scr.mq4 |
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
   Print("売値=", Bid, " 買値=", Ask);
   Print("Open[0]=", Open[0], "Open[1]=", Open[1]);
   Print("High[0]=", High[0], "High[1]=", High[1]);
   Print("Low[0]=", Low[0], "Low[1]=", Low[1]);
   Print("Close[0]=", Close[0], "Close[1]=", Open[1]);
   Print("通貨ペア=", _Symbol);
   Print("小数桁数=", _Digits);
   Print("最小値幅=", _Point);
   Print("タイムフレーム=", _Period);
  }
//+------------------------------------------------------------------+
