//+------------------------------------------------------------------+
//|                                                   test_close.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs // 実行前にパラメータ入力ウィンドウ表示
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

// 外部パラメーター
input int ticket; // ticket number


void OnStart()
  {
   bool ret_select; // 選択状況
   ret_select = OrderSelect(ticket, SELECT_BY_TICKET); // ポジションの選択
   
   bool ret_close; //決済状況
   ret_close = OrderClose(ticket, OrderLots(), OrderClosePrice(), 3); // 決済注文
   
   MessageBox("選択状況="+ret_select+" 決済状況="+ret_close);
  }
//+------------------------------------------------------------------+
