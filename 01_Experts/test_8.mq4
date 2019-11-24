#property strict

input int BBPeriod = 20; //ボリンジャーバンドの期間
input double BBDeviation = 2; //標準偏差の倍率
input double Lots = 0.01; //売買ロット数
// input int SLPoint = 20; //損切り幅（ポイント）
input int TPPoint = 50; //利食い幅（ポイント）
input int Slippage = 3;

int Ticket = 0; //チケット番号
int Magic = 20191112; //マジックナンバー

//初期化関数
int OnInit() {
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
         Ticket = OrderTicket();
         break;
      }
   }
   return(INIT_SUCCEEDED);
}

//ティック時実行関数
void OnTick() {

   // 一本前のボリンジャーバンド
   double BBUpper1 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double BBLower1 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double BBMain1  = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_MAIN, 1);
   //　二本前のボリンジャーバンド
   double BBUpper2 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_UPPER, 2);
   double BBLower2 = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_LOWER, 2);
   double BBMain2  = iBands(_Symbol, 0, BBPeriod, BBDeviation, 0, PRICE_CLOSE, MODE_MAIN, 2);
   int pos = 0; //ポジションの状態
  
   //未決済ポジションの有無
   if(OrderSelect(Ticket, SELECT_BY_TICKET) && OrderCloseTime() == 0) {
      if(OrderType() == OP_BUY) pos = 1; //買いポジション
      if(OrderType() == OP_SELL) pos = -1; //売りポジション
   }
  
   //指標値の表示
   Comment(
      "pos=", pos, 
      "\nClose[2]=", Close[2], "Close[1]=", Close[1],
      "\nBBUpper2=", BBUpper2, "BBUpper1=", BBUpper1,
      "\nBBMain2=", BBMain2, "BBMain1=", BBMain1,
      "\nBBLower2=", BBLower2, "BBLower1=", BBLower1
      );
   
  
   bool ret; //決済状況
/*   //売りポジションの決済シグナルがあれば決済注文
   if(pos < 0 && Close[2] >= BBMain2 && Close[1] < BBMain1){
      ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), Slippage, clrOrange);
      if(ret) pos = 0; //決済成功すればポジションなしに
   }
   
   //買いポジションの決済シグナルがあれば決済注文
   if(pos > 0 && Close[2] <= BBMain2 && Close[1] > BBMain1){
      ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), Slippage, clrOrange);
      if(ret) pos = 0; //決済成功すればポジションなしに
   }   
*/
   
   if(Close[2] >= BBLower2 && Close[1] < BBLower1) { //買いシグナル
      //ポジションが無ければ買い注文
      if(pos == 0) Ticket = OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, 0 /*Ask-SLPoint*_Point*/, Ask+TPPoint*_Point, NULL, Magic, 0, clrBlue);
  }
  
   if(Close[2] <= BBUpper2 && Close[1] > BBUpper1) { //売りシグナル
      //ポジションが無ければ売り注文
      if(pos == 0) Ticket = OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, 0 /*Bid+SLPoint*_Point*/, Bid-TPPoint*_Point, NULL, Magic, 0, clrRed);
   }
}

//カスタム評価関数
double OnTester() {
   //（リカバリーファクター）－（プロフィットファクター）
   return(TesterStatistics(STAT_PROFIT)/TesterStatistics(STAT_BALANCE_DD)-TesterStatistics(STAT_PROFIT_FACTOR));

}