int TickCount = 0; //ティック回数

//ティック時実行関数
void OnTick()
{
   TickCount++; //ティックをカウント
   Comment("TickCunt = ", TickCount);
   //グローバル変数に保存
   GlobalVariableSet("Gvar_ea7_1", TickCount);
}

//初期化関数
void OnInit()
{
   //グローバル変数から取得
   TickCount = GlobalVariableGet("Gvar_ea7_1");
}
