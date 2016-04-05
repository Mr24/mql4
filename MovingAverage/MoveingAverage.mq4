//+------------------------------------------------------------------+
//|                                      VsV.myql4.MovingAverage.mq4 |
//|                                Copyright(c) 2016, VerysVery Inc. |
//|                               https://github.com/verysvery/mql4/ |
//|                                                 Since:2016.03.11 |
//|                                Released under the Apache license |
//|					  	  https://opensource.org/licenses/Apache-2.0 |
//+------------------------------------------------------------------+
#property copyright "Copyright(c) 2016 -, VerysVery Inc."
#property link      "https://github.com/verysvery/mql4/"
#property description "VsV.mql4.MovingAverage - Ver.0.0.1 Update:2016.04.05"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

//--- Indicator parameters
input int            InpMAPeriod=200;        // Period
input int            InpMAShift=0;          // Shift
input ENUM_MA_METHOD InpMAMethod=MODE_EMA;  // Method

//--- Indicator buffer
double ExtLineBuffer[];


//+------------------------------------------------------------------+
//| Custom Indicator Initialization Function                         |
//+------------------------------------------------------------------+
int OnInit(void) {
	string short_name;
 	int    draw_begin=0;

  	//--- Indicator Short Name
  	short_name="EMA(";

  	IndicatorShortName(short_name+string(InpMAPeriod)+")");
  	IndicatorDigits(Digits);
  
  	//--- Drawing Settings
 	SetIndexStyle(0,DRAW_LINE);
	SetIndexShift(0,InpMAShift);
 	SetIndexDrawBegin(0,draw_begin);

  	//--- Indicator Buffers Mapping
  	SetIndexBuffer(0,ExtLineBuffer);

  	//--- Initialization Done
  	return(INIT_SUCCEEDED);

}
//+---


//+------------------------------------------------------------------+
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,		//# Each rate the Number of elements
                const int prev_calculated,	//# Computed the Number of elements
                const datetime &time[],		//# The Time Sequence of each
                const double &open[],		//# Open Price Array
                const double &high[],		//# High Price Array
                const double &low[],		//# Lows Price Array
                const double &close[],		//# Close Price Array
                const long &tick_volume[],	//# Tick Count
                const long &volume[],		//# The Real Volume
                const int &spread[]) {		//# Spread

	//--- Check for Bars Count
	if(rates_total<InpMAPeriod-1 || InpMAPeriod<2)
    	return(0);

    //--- Counting from 0 to rates_total
  	ArraySetAsSeries(ExtLineBuffer,false);	//# OLD => New
  	ArraySetAsSeries(close,false);			//# OLD => New

  	//--- First Calculation or Number of Bars was Changed
  	if(prev_calculated==0)
    	ArrayInitialize(ExtLineBuffer,0);	//# ExtLineBuffer=0 : ALL

    //--- Calculation
    CalculateEMA(rates_total,prev_calculated,close);

    //--- Return Value of prev_calculated for Next Call
    return(rates_total);

}
//+---


//+---------------------------------------------------------------------+
//|  Exponential Moving Average 										|
//+---------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,const double &price[]) {
	int    i,limit;
	double SmoothFactor=2.0/(1.0+InpMAPeriod);

	//--- First Calculation or Number of Bars was Changed
	if(prev_calculated==0) {
		limit=InpMAPeriod;
		ExtLineBuffer[0]=price[0];

		for(i=1; i<limit; i++)
			ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
	}
	else
		limit=prev_calculated-1;

	//--- Main Loop
	for(i=limit; i<rates_total && !IsStopped(); i++)
		ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);

}
//+---


//+------------------------------------------------------------------+