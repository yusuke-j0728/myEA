#property strict

input double Lots = 0.01; //売買ロット数
input int PositionCount = 3; //最大ポジション数
input int TPPoint = 500; //利食い幅（ポイント）
input int SLPoint = 300; //損切り幅（ポイント）
input int Slippage = 3;
input double TrailingStop = 50; //トレイリングストップ幅

input int MomPeriod = 20; //モメンタムの期間
input int FastMAPeriod = 20; //短期移動平均の期間
input int SlowMAPeriod = 50; //長期移動平均の期間
input int RSIPeriod = 14; //RSIの期間

input int Magic = 20200314; //マジックナンバー

int pos = 0; //注文数
double Price = 0; //約定価格
int BuySell = 0; //買いポジションまたは売りポジション
int Ticket = 0; //チケット

//初期化関数
int OnInit() {
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
         pos++;
      }
   }
   return(INIT_SUCCEEDED);
}

//ティック時実行関数
void OnTick() {

   static datetime time = Time[0];

   //一本前のモメンタム
   double mom1 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 1);
   double mom2 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 2);
   
   pos = 0; // count order

   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
         pos++;
      }
   }
   
   //１本前と２本前の移動平均
   double FastMA1 = iMA(_Symbol, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   double FastMA2 = iMA(_Symbol, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 2);
   double SlowMA1 = iMA(_Symbol, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
   double SlowMA2 = iMA(_Symbol, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 2);
   
   //１本前のRSI
   double RSI1 = iRSI(_Symbol, 0, RSIPeriod, PRICE_CLOSE, 1);
  
   //指標値の表示
   Comment(
      "time[0]=", Time[0] , "  ,  time=", time,
      "\npos=", pos, 
      "\nClose[2]=", Close[2], "  ,  Close[1]=", Close[1],
      "\nmom1=", mom1, "  ,  mom2=", mom2,
      "\nFastMA1=", FastMA1, "  ,  FastMA2=", FastMA2,
      "\nSlowMa1=", SlowMA1, "  ,  SlowMA1=", SlowMA2,
      "\nRSI1=", RSI1,
      "\nAsk=", Ask, "\nBid=", Bid      
      );   
  
   if(Time[0] != time){
      //買いポジション
      if(((mom1 > 100) && (mom2 > 100)) && (FastMA2 <= SlowMA2 && FastMA1 > SlowMA1)) { //買いシグナル
         //現在のポジション数が最大ポジション数未満であれば買い注文
         if(pos < PositionCount){
            OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, Ask-SLPoint*_Point, Ask+TPPoint*_Point, NULL, Magic, 0, clrBlue);
         } 
      }
  
      //売りポジション
      if(((mom1 < 100) && (mom2 < 100)) && (FastMA2 >= SlowMA2 && FastMA1 < SlowMA1)) { //売りシグナル
         //現在のポジション数が最大ポジション数未満であれば売り注文
         if(pos < PositionCount){
            OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, Bid+SLPoint*_Point, Bid-TPPoint*_Point, NULL, Magic, 0, clrRed);
         } 
      }
      time = Time[0];
   
      for(int i=0; i<OrdersTotal(); i++) {
         if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
            Ticket = OrderTicket();
            if(OrderSelect(Ticket, SELECT_BY_TICKET) && OrderCloseTime() == 0) {
               if(OrderType() == OP_BUY) BuySell = 1; //買いポジション
               if(OrderType() == OP_SELL) BuySell = -1; //売りポジション
            }
            if(BuySell == 1){
               if(TrailingStop > 0){
                  if(Bid > OrderOpenPrice()+Point*TrailingStop ){
                     if(OrderStopLoss() < Bid-Point*TrailingStop){
                        OrderModify(Ticket,OrderOpenPrice(), Bid-Point*TrailingStop, OrderTakeProfit(),0);
                     }
                  }
               }
            }
            if(BuySell == -1){
               if(TrailingStop > 0){
                  if(Ask < OrderOpenPrice()-Point*TrailingStop){
                     if(OrderStopLoss() > Ask+Point*TrailingStop){
                        OrderModify(Ticket,OrderOpenPrice(),Ask+Point*TrailingStop, OrderTakeProfit(),0);
                     }
                  }
               }
            }
         }  
      }
   }
}