#property strict

//EAをチャートに挿入した直後
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
  
//EAをチャートから削除する直前
void OnDeinit(const int reason)
  {
  }
  
input int MomPeriod = 20; //モメンタムの期間
input double Lots = 0.1; //売買ロット数

int Ticket = 0; //チケット番号
  
//価格が更新されるタイミング(ティック）
//ティック時実行関数
void OnTick()
  {
   //一本前のモメンタム
   double mom1 = iMomentum(_Symbol, 0, MomPeriod, PRICE_CLOSE, 1);
   
   int pos = 0; //ポジションの状態
   //未決済ポジションの有無
   if(OrderSelect(Ticket, SELECT_BY_TICKET) && OrderCloseTime() == 0) {
      if(OrderType() == OP_BUY) pos = 1; //買いポジション
      if(OrderType() == OP_SELL) pos = -1; //売りポジション
   }  
   
   bool ret; //決済状況
   if(mom1 > 100) {  //買いシグナル
      //売りポジションがあれば決済状況
      if(pos < 0) {
         ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), 0);
         if(ret) pos = 0; //決済すればポジションなしに
      }
      
      //ポジションが無ければ買い注文
      if(pos == 0) Ticket = OrderSend(_Symbol, OP_BUY, Lots, Ask, 0, 0, 0); //買い注文  
      
   }
   
   if(mom1 < 100) { //売りシグナル
      //買いポジションがあれば決済注文
      if(pos > 0) {
         ret = OrderClose(Ticket, OrderLots(), OrderClosePrice(), 0);
         if(ret) pos = 0; //決済すればポジションなしに
      }   
      //ポジションが無ければ売り注文
      if(pos == 0) Ticket = OrderSend(_Symbol, OP_SELL, Lots, Bid, 0, 0, 0); //売り注文
   }
  }

