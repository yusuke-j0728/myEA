//本書ライブラリ
#include "LibEA4.mqh"

input int RSIPeriod = 5; //RSIの期間
input int EnvPeriod = 200; //エンベロープの期間
input double EnvDev = 0.1; //偏差％
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
   //１本前のRSI
   double RSI1 = iRSI(_Symbol, 0, RSIPeriod, PRICE_CLOSE, 1);

   int ret = 0; //シグナルの初期化

   //買いシグナル
   if(RSI1 < 30) ret = 1;
   //売りシグナル
   if(RSI1 > 70) ret = -1;

   return ret; //シグナルの出力
}

//フィルタ関数
int FilterSignal(int signal)
{
   //１本前のエンベロープ
   double EnvUpper1= iEnvelopes(_Symbol, 0, EnvPeriod, MODE_SMA, 0, PRICE_CLOSE, EnvDev, MODE_UPPER, 1);
   double EnvLower1 = iEnvelopes(_Symbol, 0, EnvPeriod, MODE_SMA, 0, PRICE_CLOSE, EnvDev, MODE_LOWER, 1);

   int ret = 0; //シグナルの初期化

   //買いシグナルのフィルタ
   if(signal > 0 && Close[1] > EnvUpper1) ret = signal;

   //売りシグナルのフィルタ
   if(signal < 0 && Close[1] < EnvLower1) ret = signal;

   return ret; //シグナルの出力
}
