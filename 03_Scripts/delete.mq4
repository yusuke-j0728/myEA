/*
+--------+
http://fxcom.info All Rights Reserved
+--------+
*/
#property show_confirm
int totalPendingOrders = 0;

int start()
  {
   int    Order_Type, total;

   total=OrdersTotal();
   
   for(int a=0; a<total; a++)
     {
      if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES))
        {
         Order_Type=OrderType();
         if(Order_Type!=OP_BUY && Order_Type!=OP_SELL)
           {
            totalPendingOrders++;
            }
         }
   }
   
   for(int b=0; b<totalPendingOrders; b++)
   {
      OrderSelect(b,SELECT_BY_POS,MODE_TRADES);
      Order_Type=OrderType();
      if(Order_Type!=OP_BUY && Order_Type!=OP_SELL && Symbol()==OrderSymbol())
      {
        OrderDelete(OrderTicket());
      }
   }
   
   return(0);
  }
//+------------------------------------------------------------------+*/
