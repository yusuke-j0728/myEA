#property copyright "yusuke_EA_nanpin @20200322"
#property strict

input double Lots = 0.1; //売買ロット数
input int MaxPositions = 6; //最大ポジション数
input int TPPoint = 1000; //利食い幅（オリジナル）(Pips)
input int SLPoint = 0; //損切り幅（オリジナル）(Pips) 0の場合損切りなし
input int Slippage = 3;
//トレイリングストップ
input double TrailingStop = 0; //トレイリングストップ幅 0の場合トレイリングなし
//ナンピン
extern double  LotMultiple          = 2;          //ナンピンロット倍数
extern double  SpacePips            = 500;        //ナンピン幅(Pips)
extern double  TargetProfit         = 30;        //利食い額(ナンピン)(JPY)
extern double  LossCut              = 0;          //損切り額(ナンピン) 0の場合損切りなし

input int MomPeriod = 20; //モメンタムの期間
input int FastMAPeriod = 20; //短期移動平均の期間
input int SlowMAPeriod = 50; //長期移動平均の期間
input int RSIPeriod = 14; //RSIの期間

input int Magic = 20200322; //マジックナンバー

int pos; //注文数
int pos_cnt_buy;
int pos_cnt_sell;
double profit_buy;
double profit_sell;
double lowest_buy;
double highest_sell;
double lastlots_buy;
double lastlots_sell;
double Price = 0; //約定価格
int BuySell = 0; //買いポジションまたは売りポジション
int Ticket = 0; //チケット
bool close_mode_buy;
bool close_mode_sell;
double order_lots;
double nanpin_pips;

//口座縛り
int oweneraccountnumber = 123456;


//初期化関数
int OnInit() {
   return(INIT_SUCCEEDED);
}

//ティック時実行関数
void OnTick() {

    if(AccountNumber() == oweneraccountnumber){

        static datetime time = Time[0];

        //一本前のモメンタム
        double mom1 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 1);
        double mom2 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 2);
        //１本前と２本前の移動平均
        double FastMA1 = iMA(_Symbol, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
        double FastMA2 = iMA(_Symbol, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 2);
        double SlowMA1 = iMA(_Symbol, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
        double SlowMA2 = iMA(_Symbol, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 2);
        //１本前のRSI
        double RSI1 = iRSI(_Symbol, 0, RSIPeriod, PRICE_CLOSE, 1);
        
        pos = 0; // count order
        for(int i=0; i<OrdersTotal(); i++) {
            if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
                pos++;
            }
        }
        
        pos_cnt_buy = 0;
        pos_cnt_sell = 0;
        profit_buy = 0;
        profit_sell = 0;
        lowest_buy = -1;
        highest_sell = -1;
        lastlots_buy = 0;
        lastlots_sell = 0;
        for(int i=0; i<OrdersTotal(); i++){
            if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
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
        }
        
        //決済::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        //買いポジ
        if(pos_cnt_buy >= 2){
            if(profit_buy >= TargetProfit || (LossCut > 0 && profit_buy <= -LossCut) || close_mode_buy){
                if(CloseAll(OP_BUY)){
                    pos_cnt_buy = 0;
                    close_mode_buy = false;
                }
                else{
                    close_mode_buy = true;
                    //return(0);
                }
            }
        }
        else close_mode_buy = false;
        
        //売りポジ
        if(pos_cnt_sell >= 2){
            if(profit_sell >= TargetProfit || (LossCut > 0 && profit_sell <= -LossCut) || close_mode_sell){
                if(CloseAll(OP_SELL)){
                    pos_cnt_sell = 0;
                    close_mode_sell = false;
                }
                else{
                    close_mode_sell = true;
                    //return(0);
                }
            }
        }
        else close_mode_sell = false;  


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
                if(pos_cnt_buy < 1){
                    if(SLPoint != 0){
                        OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, Ask-SLPoint*_Point, Ask+TPPoint*_Point, "Buy_Original", Magic, 0, clrBlue);
                    }
                    if(SLPoint == 0){
                        OrderSend(_Symbol, OP_BUY, Lots, Ask, Slippage, 0, Ask+TPPoint*_Point, "Buy_Original", Magic, 0, clrBlue);
                    }
                } 
            }
        
            //売りポジション
            if(((mom1 < 100) && (mom2 < 100)) && (FastMA2 >= SlowMA2 && FastMA1 < SlowMA1)) { //売りシグナル
                //現在のポジション数が最大ポジション数未満であれば売り注文
                if(pos_cnt_sell < 1){
                    if(SLPoint != 0){
                        OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, Bid+SLPoint*_Point, Bid-TPPoint*_Point, "Sell_Original", Magic, 0, clrRed);
                    }
                    if(SLPoint == 0){
                        OrderSend(_Symbol, OP_SELL, Lots, Bid, Slippage, 0, Bid-TPPoint*_Point, "Sell_Original", Magic, 0, clrRed);
                    }
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
            
            //ナンピン
            //買い
            if(pos_cnt_buy >= 1 && pos_cnt_buy < MaxPositions){
                nanpin_pips = SpacePips * pos_cnt_buy;
                if(Ask <= lowest_buy - nanpin_pips * _Point){
                    order_lots = lastlots_buy * LotMultiple;
                    if(SLPoint != 0){
                        OrderSend(Symbol(),OP_BUY,order_lots,Ask,Slippage,Ask-SLPoint*_Point, Ask+TPPoint*_Point,"buy_nanpin",Magic,0,Blue);
                    }
                    if(SLPoint == 0){
                        OrderSend(Symbol(),OP_BUY,order_lots,Ask,Slippage, 0, Ask+TPPoint*_Point,"buy_nanpin",Magic,0,Blue);
                    }
                }
            }
            //売り
            if(pos_cnt_sell >= 1 && pos_cnt_sell < MaxPositions){
                nanpin_pips = SpacePips * pos_cnt_sell;
                if(Bid >= highest_sell + nanpin_pips * _Point){
                    order_lots = lastlots_sell * LotMultiple;
                    if(SLPoint != 0){
                    OrderSend(Symbol(),OP_SELL,order_lots,Bid,Slippage,Bid+SLPoint*_Point, Bid-TPPoint*_Point,"sell_nanpin",Magic,0,Red);
                    }
                    if(SLPoint == 0){
                    OrderSend(Symbol(),OP_SELL,order_lots,Bid,Slippage, 0, Bid-TPPoint*_Point,"sell_nanpin",Magic,0,Red);
                    }
                }
            }
        }
    } else {
        Alert("Usererror!Cannot Trading.");
    }
}

bool CloseAll(int type){
   for (int i=OrdersTotal()-1; i>=0; i--) {
      if(!OrderSelect(i, SELECT_BY_POS)) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != Magic) continue;
      if(OrderType() != type) continue;
      if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)){
         Print("Close Error");
         return(false);
      }       
   }
   return(true);
}

