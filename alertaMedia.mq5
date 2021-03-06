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

input ENUM_TENDENCIA tendencia = alcista; // Tendencia
input ushort puntosAdicionales = 0; //Distancia adicional (Puntos)

input group "Media movil"
input int _ma_period = 1100; // Periodo
input ENUM_MA_METHOD _ma_method = MODE_LWMA; // Tipo

C_AlertaMedia obj_AlertaMedia;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   const ENUM_INIT_RETCODE x = obj_AlertaMedia._OnInit(
                                  _Symbol,
                                  PERIOD_CURRENT,
                                  _ma_period,
                                  _ma_method,
                                  tendencia,
                                  puntosAdicionales
                               );

   return x;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   obj_AlertaMedia._OnTick();

   ResetLastError();
  }
//+------------------------------------------------------------------+
