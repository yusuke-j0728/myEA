//本書ライブラリ
#include "LibEA4.mqh"

input int BBPeriod = 10;  //ボリンジャーバンドの期間
input double BBDev = 2.0; //標準偏差の倍率
input double InitialLots = 0.1; //初期ロット数
input double MaxLots = 1.6;   //最大ロット数

//ティック時実行関数
void OnTick()
{
   int sig_entry = EntrySignal(); //仕掛けシグナル
   //ポジション決済
   MyOrderCloseMarket(sig_entry, sig_entry);
   //ロット数
   double lots = CalculateLots();
   //成行注文
   MyOrderSendMarket(sig_entry, 0, lots);
}

//仕掛けシグナル関数
int EntrySignal()
{
   //１本前と２本前のボリンジャーバンド
   double BBUpper1 = iBands(_Symbol, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double BBLower1 = iBands(_Symbol, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double BBUpper2 = iBands(_Symbol, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_UPPER, 2);
   double BBLower2 = iBands(_Symbol, 0, BBPeriod, BBDev, 0, PRICE_CLOSE, MODE_LOWER, 2);

   int ret = 0; //シグナルの初期化

   //買いシグナル
   if(Close[2] >= BBLower2 && Close[1] < BBLower1) ret = 1;
   //売りシグナル
   if(Close[2] <= BBUpper2 && Close[1] > BBUpper1) ret = -1;

   return ret; //シグナルの出力
}

//ロット数算出関数
double CalculateLots()
{
   double lots;
   //前回が負けトレードの場合、ロット数を前回の２倍にする
   if(MyOrderLastProfit() < 0) lots = MyOrderLastLots()*2;
   else lots = InitialLots; //それ以外の場合、初期ロット数に戻す
   if(lots > MaxLots) lots = MaxLots; //最大ロット数に制限

   return lots; //ロット数の出力
}
