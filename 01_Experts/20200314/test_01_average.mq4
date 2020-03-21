//初期設定）
//各関数を宣言します。
input int MAGIC = 884;
input int TakeProfit = 100;
input double Lot = 0.01;
int d; //Dummy for Return Value
int i; //for For Roop
string Sym; //Symbol()
double TP; //TakeProfit x Point
double PriceTotal;
double cPrice;
datetime OldTime;

//内部初期設定）
//Symbol() 関数の呼び出し時間軽減の為、Sym変数に代入します。
//色々な通貨ペアで使用できるようにTakeProfit をPoint を掛け変数TPに代入します。
//TakeProfit はint 型ですので(double)を付けています。
//**** Initialize ****
void OnInit(void){
    Sym=Symbol();
    TP=(double)TakeProfit*Point;
}

// ティック動作）
// 1.ティック単位で動作しますが、足ごとに動作するようにします。
// 2.Average()関数を呼び出し価格の合計、ポジション数の計算をしています。
// 3.ポジションがある時には価格幅を変動させつつOrderLong() 関数を呼び出します。
// 4.ポジションが無い時はOrderLong()関数を呼び出します。
//**** OnTick ****
void OnTick(){
    if(Time[0]!=OldTime){
        OldTime=Time[0];
        chkAverage();
        if(cPrice){
            if((PriceTotal+Bid)/(cPrice+1)){
                OrderLong();
                Modify();
            }
        }
    else OrderLong();
    }
}

// 発注関数）
// RSIが30以下の場合発注します。
//**** Order Long ****
void OrderLong(){
    if(iRSI(Sym,PERIOD_CURRENT,14,PRICE_CLOSE,0)<30){
        d=OrderSend(Sym,OP_BUY,Lot,Ask,5,0,Bid+TP,”AV-SYS”,MAGIC);
        Print( Bid,” “,TP);
    }
}

// 平均価格計算）
// 全てのポジションからマジックナンバーの合うポジションの合計価格と数を算出します。
//**** Check Average ****
void chkAverage(){
    PriceTotal=0;
    cPrice=0;
    for(i=OrdersTotal()-1;i>=0;i–){
        d=OrderSelect(i,SELECT_BY_POS);
        if(OrderMagicNumber()==MAGIC){
            PriceTotal+=OrderOpenPrice();
            cPrice++;
        }
    }	
}

// 利益確定額変更）
// マジックナンバーの合うポジション全ての利益確定額を変更します。
//**** Modify() **** 
void Modify(){
    for(i=OrdersTotal()-1;i>=0;i–){
        d=OrderSelect(i,SELECT_BY_POS);
        if(OrderMagicNumber()==MAGIC){
            d=OrderModify(OrderTicket(),OrderOpenPrice(),0,PriceTotal/cPrice+TP,0);
        }
    }
}