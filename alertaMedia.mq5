//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, jfdelosrios@hotmail.com"
#property link      "mailto:jfdelosrios@hotmail.com"
#property version   "1.00"
#property description "Envia mensaje cuando el precio esta cerca de "
#property description "la una cierta media movil."

#include "C_AlertaMedia.mqh"
#include "C_entradas.mqh"

C_entradas obj_entradas;

C_AlertaMedia obj_AlertaMedia[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ConfigurarGrafico()
  {

   if(!ChartSetInteger(0, CHART_MODE, CHART_LINE))
      return false;

   if(!ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrNONE))
      return false;

   if(!ChartSetInteger(0, CHART_SHOW_GRID, false))
      return false;

   if(!ChartSetInteger(0, CHART_SHOW_BID_LINE, false))
      return false;

   if(!ChartSetInteger(0, CHART_SHOW_VOLUMES, false))
      return false;

   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   struct_entradas entrada[];

   if(!MQLInfoInteger(MQL_TESTER))
     {
      if(!EventSetTimer(2))
        {
         Print("Error ", _LastError, ", linea ", __LINE__);
         return INIT_FAILED;
        }
        
     }

   if(!obj_entradas.generarEntradas("mediaAlerta", entrada))
     {
      Print("Error ", _LastError, ", linea ", __LINE__);
      return INIT_FAILED;
     }

   ArrayResize(obj_AlertaMedia,ArraySize(entrada));

   for(int i = (ArraySize(entrada) - 1); i >= 0; i--)
     {
      if(INIT_SUCCEEDED!= obj_AlertaMedia[i]._OnInit(
            entrada[i].simbolo,
            entrada[i].timeFrame,
            entrada[i].periodo,
            entrada[i].tipoMedia,
            entrada[i].puntosAdicionales
         ))
        {
         return INIT_FAILED;
        }
     }

   if(!ConfigurarGrafico())
     {
      Print("Error ", _LastError, ", linea ", __LINE__);
      return INIT_FAILED;
     }

   return INIT_SUCCEEDED;

  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

   Comment("");

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Ejecutar()
  {
   string mensaje = TimeToString(TimeCurrent()) + "\n\n";

   for(int i = (ArraySize(obj_AlertaMedia) - 1); i >= 0; i--)
     {
      obj_AlertaMedia[i]._OnTick();

      mensaje = mensaje + "\n" + obj_AlertaMedia[i].descripcion();

      if(_LastError != 0)
        {
         Print("Error ", _LastError, ", linea ", __LINE__);
         ExpertRemove();
         break;
        }
     }

   Comment(mensaje);
  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Ejecutar();
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(!MQLInfoInteger(MQL_TESTER))
      return;

   Ejecutar();
  }
//+------------------------------------------------------------------+
