//本書ライブラリ
#include "LibEA4.mqh"

input int MomPeriod = 20; //モメンタムの期間
input int ADXPeriod = 50; //ADXの期間
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
   //１本前と４本前のADX
   double ADX1 = iADX(_Symbol, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 1);
   double ADX2 = iADX(_Symbol, 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 4);

   int ret = 0; //シグナルの初期化

   //売買シグナルのフィルタ
   if(ADX1 > ADX2) ret = signal;

   return ret; //シグナルの出力
}
