#property strict

input int MomPeriod = 20; //モメンタムの期間
input int FastMAPeriod = 20; //短期移動平均の期間
input int SlowMAPeriod = 50; //長期移動平均の期間
input int RSIPeriod = 14; //RSIの期間

input double Lots = 0.01; //売買ロット数
input int SLPoint = 1000; //損切り幅（ポイント）
input int TPPoint = 200; //利食い幅（ポイント）
input int Slippage = 3;

int pos = 0; //注文数
int Magic = 20200216; //マジックナンバー
double Price = 0; //約定価格

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
      "pos=", pos, 
      "\nClose[2]=", Close[2], "Close[1]=", Close[1],
      "\nmom1=", mom1,
      "\nAsk=", Ask, "\nBid=", Bid      
      );   
  
   //買いポジション
   if(((mom1 > 100) && (mom2 > 100)) && (FastMA2 <= SlowMA2 && FastMA1 > SlowMA1)) { //買いシグナル
      //ポジションが6つ未満であれば買い注文
      if(pos < 6){
         OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, Ask-SLPoint*_Point, Ask+TPPoint*_Point, NULL, Magic, 0, clrBlue);
      } 
  }
  
   //売りポジション
   if(((mom1 < 100) && (mom2 < 100)) && (FastMA2 >= SlowMA2 && FastMA1 < SlowMA1)) { //売りシグナル
      //ポジションが6つ未満であれば売り注文
      if(pos < 6){
         OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, Bid+SLPoint*_Point, Bid-TPPoint*_Point, NULL, Magic, 0, clrRed);
      } 
   }
 
}
