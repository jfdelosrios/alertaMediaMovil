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
#include "varios.mqh"
#property strict

#include <Indicators\Trend.mqh>
#include <Indicators\TimeSeries.mqh>
#include <Trade/SymbolInfo.mqh>

CiMA MA;

CiLow Low;
CiHigh High;
CiTime Time;

CSymbolInfo simbolo;

enum ENUM_TENDENCIA
  {
   bajista,
   alcista
  };

input int _ma_period = 500; // Periodo de la media
input ENUM_MA_METHOD _ma_method = MODE_LWMA; // Tipo de la media
input ENUM_TENDENCIA tendencia = alcista; // Tendencia
input ushort puntosAdicionales = 0; //Distancia adicional (Puntos)

datetime tiempo[2];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!simbolo.Name(_Symbol))
     {
      return(INIT_FAILED);
     }

   if(!MA.Create(
         simbolo.Name(),
         PERIOD_CURRENT,
         _ma_period,
         0,
         _ma_method,
         PRICE_CLOSE
      ))
     {
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!Low.Create(simbolo.Name(),PERIOD_CURRENT))
     {
      return(INIT_FAILED);
     }

   if(!High.Create(simbolo.Name(),PERIOD_CURRENT))
     {
      return(INIT_FAILED);
     }

   if(!Time.Create(simbolo.Name(),PERIOD_CURRENT))
     {
      return(INIT_FAILED);
     }

   tiempo[0]=0;
   tiempo[1]=0;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EnviarMensaje_(const string mensaje1, const int pos)
  {

   if(tiempo[pos] == Time.GetData(pos + 1))
      return;

   const string mensaje =
      "\n" +
      simbolo.Name() +
      "\n" +
      mensaje1 +
      "\n"
      ;

   if(!EnviarMensaje(__FILE__, mensaje, true))
      return;

   tiempo[pos] = Time.GetData(pos + 1);
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   simbolo.RefreshRates();

   Time.Refresh();
   Low.Refresh();
   High.Refresh();
   MA.Refresh();

   string propiedadesMedia = "";
   propiedadesMedia = propiedadesMedia + EnumToString(_ma_method);
   propiedadesMedia = propiedadesMedia + ", ";
   propiedadesMedia = propiedadesMedia + "periodo: " ;

   propiedadesMedia = propiedadesMedia +
                      IntegerToString(_ma_period)
                      ;

   const double precioAdicional = puntosAdicionales * simbolo.Point();

   if(precioAdicional == -1)
     {

      if(_LastError != 0)
        {

         Print(
            "Error " +
            IntegerToString(_LastError) +
            ", linea " +
            IntegerToString(__LINE__)
         );

         ResetLastError();
        }

      return;
     }

   string mensaje1 = "";

   if(tendencia == alcista)
     {
      mensaje1 = "Tendencia alcista \n " + propiedadesMedia;

      Comment(
         mensaje1 +
         "\n [1]: " +
         DoubleToString(MA.Main(1), simbolo.Digits() + 1)
      );

      if((Low.GetData(1) - precioAdicional) <= MA.Main(1))
         EnviarMensaje_(mensaje1, 0);

      if((Low.GetData(2) - precioAdicional) <= MA.Main(2))
         EnviarMensaje_(mensaje1, 1);
     }

   if(tendencia == bajista)
     {
      mensaje1 = "Tendencia bajista \n " + propiedadesMedia;

      Comment(
         mensaje1 +
         "\n [1]: " +
         DoubleToString(MA.Main(1), simbolo.Digits() + 1)
      );

      if((High.GetData(1) + precioAdicional) >= MA.Main(1))
         EnviarMensaje_(mensaje1, 0);

      if((High.GetData(2) + precioAdicional) >= MA.Main(2))
         EnviarMensaje_(mensaje1, 1);
     }

  }
//+------------------------------------------------------------------+
