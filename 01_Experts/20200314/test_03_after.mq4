//+------------------------------------------------------------------+
//|                                                   NampinGale.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "脱サラトレーダー"
#property link      "http://ameblo.jp/metatrader-auto/"

extern double  Lots                 = 0.01;                 //ロット数
extern double  LotMultiple          = 2;                    //ナンピンロット倍数
extern double  SpacePips            = 10;                   //ナンピン幅（ピプス）
extern int     MaxPositions         = 5;                    //最大ポジション数
extern double  TargetProfit         = 10;                   //利食い額
extern double  LossCut              = 200;                  //損切り額 0の場合損切りなし
extern double  Slippage             = 3;                    //スリッページ
extern int     MagicNumber          = 12345;                //マジックナンバー

double _point;
int lot_digit;
double   maxlot;
double   minlot;

bool close_mode_buy;
bool close_mode_sell;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init(){
//----
   _point = Point;
   if (Digits == 3 || Digits == 5) {
      _point   *= 10;
      Slippage *= 10;
   }
   
   double lot_step = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (lot_step < 0.0001)    lot_digit = 5;
   else if(lot_step < 0.001) lot_digit = 4;
   else if(lot_step < 0.01)  lot_digit = 3;
   else if(lot_step < 0.1)   lot_digit = 2;
   else if(lot_step < 1)     lot_digit = 1;
   else lot_digit = 0;
   maxlot = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), lot_digit);
   minlot = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), lot_digit);
//----
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
   //ポジションの情報を取得する
   int pos_cnt_buy = 0;
   int pos_cnt_sell = 0;
   double profit_buy = 0;
   double profit_sell = 0;
   double lowest_buy = -1;
   double highest_sell = -1;
   double lastlots_buy;
   double lastlots_sell;
   
   for(int i=OrdersTotal()-1;i>=0;i--){
      OrderSelect(i, SELECT_BY_POS);
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != MagicNumber) continue;
      if(OrderType() == OP_BUY){
         pos_cnt_buy++;
         profit_buy += OrderProfit() + OrderSwap() + OrderCommission();
         if(lowest_buy < 0 || lowest_buy > OrderOpenPrice()){
            lowest_buy = OrderOpenPrice();
            lastlots_buy = OrderLots();
         }
      }
      else if(OrderType() == OP_SELL){
         pos_cnt_sell++;
         profit_sell += OrderProfit() + OrderSwap() + OrderCommission();
         if(highest_sell < 0 || highest_sell < OrderOpenPrice()){
            highest_sell = OrderOpenPrice();
            lastlots_sell = OrderLots();
         }
      }
   }
   
   //決済::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
   //買いポジ
   if(pos_cnt_buy > 0){
      if(profit_buy >= TargetProfit || (LossCut>0 && profit_buy <= -LossCut) || close_mode_buy){
         if(CloseAll(OP_BUY)){
            pos_cnt_buy = 0;
            close_mode_buy = false;
         }
         else{
            close_mode_buy = true;
            return(0);
         }
      }
   }
   else close_mode_buy = false;
   
   //売りポジ
   if(pos_cnt_sell > 0){
      if(profit_sell >= TargetProfit || (LossCut>0 && profit_sell <= -LossCut) || close_mode_sell){
         if(CloseAll(OP_SELL)){
            pos_cnt_sell = 0;
            close_mode_sell = false;
         }
         else{
            close_mode_sell = true;
            return(0);
         }
      }
   }
   else close_mode_sell = false;
   
   
   //Entry::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
   double lots;
   //ナンピン
   //買い
   if(pos_cnt_buy > 0 && pos_cnt_buy < MaxPositions){
      if(Ask <= lowest_buy - SpacePips * _point){
         lots = NormalizeDouble(lastlots_buy * LotMultiple, lot_digit);
         if(lots < minlot) lots = minlot;
         if(lots > maxlot) lots = maxlot;
         OrderSend(Symbol(),OP_BUY,lots,Ask,Slippage,0,0,"buy",MagicNumber,0,Blue);
      }
   }
   //売り
   if(pos_cnt_sell > 0 && pos_cnt_sell < MaxPositions){
      if(Bid >= highest_sell + SpacePips * _point){
         lots = NormalizeDouble(lastlots_sell * LotMultiple, lot_digit);
         if(lots < minlot) lots = minlot;
         if(lots > maxlot) lots = maxlot;
         OrderSend(Symbol(),OP_SELL,lots,Bid,Slippage,0,0,"sell",MagicNumber,0,Red);
      }
   }
   
   //売買シグナル
   int sign=0;
   
   //買いsign 1 売りsign -1
   if(Hour() % 2 == 0) sign = 1;
   else sign = -1;
   
   //買い条件・買い注文
   if(pos_cnt_buy == 0){
      if(sign == 1) OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,"buy",MagicNumber,0,Blue);
   }
      
   //売り条件・売り注文
   if(pos_cnt_sell == 0){
      if(sign==-1) OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,"sell",MagicNumber,0,Red);
   }
   
//----
   return(0);
}
//+------------------------------------------------------------------+


bool CloseAll(int type){
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if(!OrderSelect(i, SELECT_BY_POS)) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != MagicNumber) continue;
      if(OrderType() != type) continue;
      if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)){
         Print("Close Error");
         return(false);
      }       
   }
   return(true);
}

