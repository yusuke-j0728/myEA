//本書ライブラリ
#include "LibEA4.mqh"

input int RSIPeriod = 14; //RSIの期間
input double LimitPips = 20; //指値までの値幅(pips)
input int MaxPos = 3;     //最大ポジション数
input double Lots = 0.1; //売買ロット数

//ティック時実行関数
void OnTick()
{
   int sig_entry = EntrySignal(); //仕掛けシグナル
   //指値注文
   for(int i=0; i<MaxPos; i++)
      MyOrderSendPending(sig_entry, sig_entry, Lots, LimitPips*(i+1), 0, i);
}

//仕掛けシグナル関数
int EntrySignal()
{
   //１本前のRSI
   double RSI1 = iRSI(_Symbol, 0, RSIPeriod, PRICE_CLOSE, 1);

   int ret = 0; //シグナルの初期化

   //買いシグナル
   if(RSI1 < 30) ret = 1;
   //売りシグナル
   if(RSI1 > 70) ret = -1;

   return ret; //シグナルの出力
}
