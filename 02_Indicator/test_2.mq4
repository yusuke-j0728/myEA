//+------------------------------------------------------------------+
//|                                                       test_2.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrRed
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID

double Buf[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Buf);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int limit = rates_total - prev_calculated; // プロットするバーの数
   for(int i=0; i<limit; i++){
      Buf[i] = (Open[i]+High[i]+Low[i]+Close[i])/4;
   }


/*   Buf[0] = (Open[0]+High[0]+Low[0]+Close[0])/4;
   Buf[1] = (Open[1]+High[1]+Low[1]+Close[1])/4;
   Buf[2] = (Open[2]+High[2]+Low[2]+Close[2])/4;
   Buf[3] = (Open[3]+High[3]+Low[3]+Close[3])/4;
   Buf[4] = (Open[4]+High[4]+Low[4]+Close[4])/4;
*/
//--- return value of prev_calculated for next call
   return(rates_total - 1);
  }
//+------------------------------------------------------------------+
