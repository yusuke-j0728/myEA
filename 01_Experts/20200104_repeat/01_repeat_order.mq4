#property strict

input double orderPrice = 100; //注文開始価格
input double diff = 200; //価格の値幅
input int position = 4; //注文するポジション数

input double Lots = 0.01; //売買ロット数
input int SLPoint = 0; //損切り幅（ポイント）
input int TPPoint = 100; //利食い幅（ポイント）
input int Slippage = 3;

int pos = 0; //オープンポジション数
int Ticket = 0; //チケット番号
int Magic = 20200104; //マジックナンバー

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
  
   //指標値の表示
   Comment(
      "オープンポジション数=", pos
      );   

   //Count Position No
   pos = 0;
   for(int i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
         pos++;
      }
   }
  
   //buying limit order
   for(int i=0; i<position; i++){
      OrderSend(_Symbol, OP_BUYLIMIT, Lots, orderPrice-diff*_Point*i, Slippage, 0, (orderPrice-diff*_Point*i)+TPPoint*_Point, NULL, Magic, 0, clrBlue);    
   }
  
   //buying stop order
   for(int i=0; i<position; i++){
      OrderSend(_Symbol, OP_BUYSTOP, Lots, orderPrice+diff*_Point*i, Slippage, 0, (orderPrice+diff*_Point*i)+TPPoint*_Point, NULL, Magic, 0, clrBlue);
   }

   //利益確定注文後、同条件で再度エントリー
   if(pos < position*2){
      for(int i = OrdersHistoryTotal() - 1; i >= 0; i--){
         if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false){
            break;
         }
         if(OrderSymbol() != Symbol() || OrderMagicNumber() != Magic){
            continue;
         }
         //コメントに[tp]という文字列が存在していたら、tp決済と判断
         if(StringFind(OrderComment(), "[tp]") >= 0){
            double orderNewPrice = OrderOpenPrice();
            double orderNewClosePrice = OrderClosePrice();
            OrderSend(_Symbol, OP_BUYLIMIT, Lots, orderNewPrice, Slippage, 0, orderNewClosePrice,NULL, Magic, 0, clrBlue); 
            break;
         }
      }
   }
   
}
