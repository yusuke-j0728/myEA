//+------------------------------------------------------------------+
//|                                                   NampinGale.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "脱サラトレーダー"
#property link      "http://ameblo.jp/metatrader-auto/"

extern double  Lots                 = 0.01;                 //ロット数
extern int     TakeProfit           = 20;                    //リミットのPIPS数 0の場合リミットなし
extern int     StopLoss             = 20;                    //ストップロスのPIPS数 0の場合ストップロスなし
extern double  Slippage             = 3;                    //スリッページ
extern int     MagicNumber          = 12345;                //マジックナンバー

double _point;
int bar;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init(){
   _point = Point;
   if (Digits == 3 || Digits == 5) {
      _point   *= 10;
      Slippage *= 10;
   }
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start(){
//----
   //ポジションの数をカウントする
   int pos_cnt = 0;
   for(int i=OrdersTotal()-1;i>=0;i--){
      OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != MagicNumber) continue;
      pos_cnt++;
   }
   
   //売買シグナル
   int sign=0;
   
   //買いsign 1 売りsign -1
   if(Hour() % 2 == 0) sign = 1;
   else sign = -1;
   
   //Entry::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
   
   int ticket=-1;
   double sl=0,tp=0;
   
   if(bar!=Bars){
      if(pos_cnt < 1){
         //買い条件・買い注文
         if(sign == 1){
            if(StopLoss > 0) sl = Ask-StopLoss*_point;
            if(TakeProfit > 0) tp = Ask+TakeProfit*_point;
            
            ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,"buy",MagicNumber,0,Blue);
            if(ticket>=0){
               if(sl > 0 || tp > 0){
                  OrderSelect(ticket,SELECT_BY_TICKET);
                  OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0);
               }
               bar=Bars;
            }
         }
      
         //売り条件・売り注文
         if(sign==-1){
            if(StopLoss>0) sl = Bid+StopLoss*_point;
            if(TakeProfit>0) tp = Bid-TakeProfit*_point;
            
            ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,"sell",MagicNumber,0,Red);
            if(ticket>=0){
               if(sl > 0 || tp > 0){
                  OrderSelect(ticket,SELECT_BY_TICKET);
                  OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0);
               }
               bar=Bars;
            }
         }
      }
   }   
//----
   return(0);
}
//+------------------------------------------------------------------+


