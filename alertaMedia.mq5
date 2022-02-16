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
input ushort distanciaAdicional = 0; //Distancia adicional (Pixeles)

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
//| Convierte una distancia vertical de pixeles a unidades de precio |
//| (cant de puntos * Point())                                       |
//|                                                                  |
//| Si la conversion no es satisfactoria devuelve -1                 |
//+------------------------------------------------------------------+
double CalcularDistanciaPrecio(const ushort _distanciaPixeles)
  {

   int      sub_window;
   datetime time1;
   double   price1 = 0;
   double   price2 = 0;

   if(!ChartXYToTimePrice(
         0,          // identificador del gráfico
         0,          // coordinada X en el gráfico
         0,          // coordinada Y en el gráfico
         sub_window, // número de subventana
         time1,      // fecha/hora en el gráfico
         price1      // precio en el gráfico
      ))
      return -1;

   if(!ChartXYToTimePrice(
         0,                 // identificador del gráfico
         0,                 // coordinada X en el gráfico
         _distanciaPixeles, // coordinada Y en el gráfico
         sub_window,        // número de subventana
         time1,             // fecha/hora en el gráfico
         price2             // precio en el gráfico
      ))
      return -1;

   return MathAbs(price1 - price2);
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

   const double precioAdicional = CalcularDistanciaPrecio(
                                     distanciaAdicional
                                  );

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
