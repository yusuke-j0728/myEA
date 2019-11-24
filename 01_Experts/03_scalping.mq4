#property strict

input int MomPeriod = 20; //モメンタムの期間
input int FastMAPeriod = 10; //短期移動平均の期間
input int SlowMAPeriod = 40; //長期移動平均の期間
input double Lots = 0.01; //売買ロット数
input int SLPoint = 1000; //損切り幅（ポイント）
input int TPPoint = 100; //利食い幅（ポイント）
input int TPPoint2 = 100; //利食いエントリー（ポイント）
input int Slippage = 3;

int Ticket = 0; //チケット番号
int Magic = 20191119; //マジックナンバー
double Price = 0; //約定価格

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
   // 一本前の移動平均
   double FastMA1 = iMA(_Symbol, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   double SlowMA1 = iMA(_Symbol, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   //　二本前の移動平均
   double FastMA2 = iMA(_Symbol, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 2);
   double SlowMA2 = iMA(_Symbol, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 2);  
   
   int pos = 0; //ポジションの状態
   
   //未決済ポジションの有無
   if(OrderSelect(Ticket, SELECT_BY_TICKET) && OrderCloseTime() == 0) {
      if(OrderType() == OP_BUY) pos = 1; //買いポジション
      if(OrderType() == OP_SELL) pos = -1; //売りポジション
   }
   
   if(OrderSelect(Ticket, SELECT_BY_TICKET)==true){
      Price = OrderOpenPrice();   
   }

  
   //指標値の表示
   Comment(
      "pos=", pos, 
      "\nPrice", Price,
      "\nClose[2]=", Close[2], "Close[1]=", Close[1],
      "\nmom1=", mom1,
      "\nAsk=", Ask, "\nBid=", Bid      
      );   
  
   if(FastMA2 <= SlowMA2 && FastMA1 > SlowMA1) { //買いシグナル
      //ポジションが無ければ買い注文
      if(pos == 0){
         Ticket = OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, Ask-SLPoint*_Point, Ask+TPPoint*_Point, NULL, Magic, 0, clrBlue);
         Alert("Buy ", _Symbol, " at ", Ask);
         SendNotification("Buy "+_Symbol+" at "+Ask);
      } 
  }
  
   if(FastMA2 >= SlowMA2 && FastMA1 < SlowMA1) { //売りシグナル
      //ポジションが無ければ売り注文
      if(pos == 0){
         Ticket = OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, Bid+SLPoint*_Point, Bid-TPPoint*_Point, NULL, Magic, 0, clrRed);
         Alert("Sell ", _Symbol, " at ", Bid);
         SendNotification("Sell "+_Symbol+" at "+Bid);
      } 
   }

   
   bool ret; //決済状況
   //売りポジションの決済シグナルがあれば決済注文
   if(pos < 0 && Ask <= Price - TPPoint2*_Point){
      ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), Slippage, clrOrange);
      if(ret){
         Alert("Close ", _Symbol, " at ", OrderClosePrice());
         SendNotification("Close "+_Symbol+" at "+OrderClosePrice());
         pos = 0; //決済成功すればポジションなしに      
      } 
   }

   
   //買いポジションの決済シグナルがあれば決済注文
   if(pos > 0 && Bid >= Price + TPPoint2*_Point){
      ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), Slippage, clrOrange);
      if(ret){
         Alert("Close ", _Symbol, " at ", OrderClosePrice());
         SendNotification("Close "+_Symbol+" at "+OrderClosePrice());
         pos = 0; //決済成功すればポジションなしに      
      }
   }
   
}
