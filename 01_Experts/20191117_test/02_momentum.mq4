#property strict

input int MomPeriod = 20; //モメンタムの期間
input double Lots = 0.01; //売買ロット数
input int SLPoint = 1000; //損切り幅（ポイント）
input int TPPoint = 300; //利食い幅（ポイント）
input int Slippage = 10;

int Ticket = 0; //チケット番号
int Magic = 20191118; //マジックナンバー

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

   //一本前のモメンタム
   double mom1 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 1);
   double mom2 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 2);
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
      "\nmom1", mom1, "mom2=", mom2
      );   
  
   if(mom1 > 100 && mom2 > 100) { //買いシグナル
      //ポジションが無ければ買い注文
      if(pos == 0) Ticket = OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, Ask-SLPoint*_Point, Ask+TPPoint*_Point, NULL, Magic, 0, clrBlue);
      if(Ticket > 0) {
         Alert("Buy ", _Symbol, " at ", Ask);
         SendNotification("Buy "+_Symbol+" at "+Ask);
      }
  }
  
   if(mom1 < 100 && mom2 < 100) { //売りシグナル
      //ポジションが無ければ売り注文
      if(pos == 0) Ticket = OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, Bid+SLPoint*_Point, Bid-TPPoint*_Point, NULL, Magic, 0, clrRed);
      if(Ticket > 0) {  
         Alert("Sell ", _Symbol, " at ", Bid);
         SendNotification("Sell "+_Symbol+" at "+Bid);
      }
   }
}
