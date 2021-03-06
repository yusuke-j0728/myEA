//本書ライブラリ
#include "LibEA4.mqh"

input int MomPeriod = 20; //モメンタムの期間
input int FastATRPeriod = 20; //短期ATRの期間
input int SlowATRPeriod = 200; //長期ATRの期間
input double Lots = 0.1; //売買ロット数

//ティック時実行関数
void OnTick()
{
   int sig_entry = EntrySignal(); //仕掛けシグナル
   int sig_filter = FilterSignal(sig_entry); //トレンドフィルタ
   //成行売買
   MyOrderSendMarket(sig_filter, sig_entry, Lots);
}

//仕掛けシグナル関数
int EntrySignal()
{
   //１本前のモメンタム
   double mom1 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 1);

   int ret = 0; //シグナルの初期化

   //買いシグナル
   if(mom1 > 100) ret = 1;
   //売りシグナル
   if(mom1 < 100) ret = -1;

   return ret; //シグナルの出力
}

//フィルタ関数
int FilterSignal(int signal)
{
   //１本前のATR
   double FastATR1 = iATR(_Symbol, 0, FastATRPeriod, 1);
   double SlowATR1 = iATR(_Symbol, 0, SlowATRPeriod, 1);

   int ret = 0; //シグナルの初期化

   //売買シグナルのフィルタ
   if(FastATR1 > SlowATR1) ret = signal;

   return ret; //シグナルの出力
}
