int TickCount = 0; //ティック回数

//ティック時実行関数
void OnTick()
{
   TickCount++; //ティックをカウント
   Comment("TickCunt = ", TickCount);
   
   //ファイルへ書き込むためにファイルオープン
   int handle = FileOpen("file_ea7_2.txt", FILE_WRITE|FILE_TXT, '=');
   if(handle != INVALID_HANDLE)
   {
      //ファイルへデータの書き込み
      FileWrite(handle, "TickCount", TickCount);
      FileClose(handle); //ファイルクローズ
   }
}

//初期化関数
void OnInit()
{
   //ファイルから読み込むためにファイルオープン
   int handle = FileOpen("file_ea7_2.txt", FILE_READ|FILE_TXT, '=');
   if(handle != INVALID_HANDLE)
   {
      while(!FileIsEnding(handle)) //ファイルの終わりまで繰り返す
      {
         //ファイルからデータの読み込み
         string name = FileReadString(handle);
         int var = FileReadNumber(handle);
         if(name == "TickCount") TickCount = var;
      }
      FileClose(handle); //ファイルクローズ
   }
}
