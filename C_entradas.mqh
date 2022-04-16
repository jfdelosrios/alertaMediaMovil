//+------------------------------------------------------------------+
//|                                                   C_entradas.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "registro.mqh"


struct _struct_entradas
  {
   string            simbolo;
   string            metodo;
   int               periodo;
   ushort            puntosAdicionales;
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_entradas
  {

private:

   ENUM_MA_METHOD    tipoMediaToENUM(const string _tipoMedia);
   int               totalRegistros(const int db, const string tabla);

public:
                     C_entradas();
                    ~C_entradas();

   bool              generarEntradas(
      const string filename,
      struct_entradas &entradas[]
   );

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_entradas::C_entradas()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
C_entradas::~C_entradas()
  {
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD C_entradas::tipoMediaToENUM(string _tipoMedia)
  {

   StringToUpper(_tipoMedia);

   if(_tipoMedia == "SMA")
      return MODE_SMA;

   if(_tipoMedia == "EMA")
      return MODE_EMA;

   if(_tipoMedia == "LWMA")
      return MODE_LWMA;

   if(_tipoMedia == "SMMA")
      return MODE_LWMA;

   Print("ALERTA: "+ _tipoMedia + "No es un tipo de media. se pone una media ponderada.");

   return MODE_LWMA;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int C_entradas::totalRegistros(const int db, const string tabla)

  {

   int request = DatabasePrepare(db, "SELECT COUNT(*) AS totalRegistros FROM " + tabla + ";");
   if(request == INVALID_HANDLE)
     {
      return -1;
     }

   int _salida=-1;

   while(DatabaseRead(request))
     {
      if(DatabaseColumnInteger(request, 0, _salida))
         break;
     }

   DatabaseFinalize(request);
   return _salida;
  }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
bool C_entradas::generarEntradas(
   const string filename,
   struct_entradas &entradas[]
)
  {
   _struct_entradas registro;

   const int db = DatabaseOpen(
                     filename,
                     DATABASE_OPEN_COMMON|DATABASE_OPEN_READONLY
                  );

   if(db == INVALID_HANDLE)
     {
      Print("Problema para abir ", filename, ".sqlite en ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files");
      return false;
     }

   string tabla = "Media";

   if(!DatabaseTableExists(
         db,      // manejador de base de datos recibido en DatabaseOpen
         tabla
      ))
     {
      Print("La tabla " + tabla + " no existe.");
      DatabaseClose(db);
      return false;
     }

   int x = totalRegistros(db, tabla);

   if(x == -1)
     {
      Print("La tabla " + tabla + " no existe.");
      DatabaseClose(db);
      return false;
     }

   if(ArrayResize(entradas, x) == -1)
     {
      Print("ArrayResize(entradas, x) == -1");
      DatabaseClose(db);
      return false;
     }

   int request = DatabasePrepare(db, "SELECT simbolo, metodo, periodo, puntosAdicionales FROM "+tabla+";");

   if(request == INVALID_HANDLE)
     {
      Print("DB: ", tabla, " request failed with code ", GetLastError());
      DatabaseClose(db);
      return false;
     }

   string _simbolo;

   for(int i = (ArraySize(entradas) - 1); i >= 0; i--)
     {

      if(!DatabaseReadBind(request, registro))
         return false;


      _simbolo = registro.simbolo;

      if(!StringToUpper(_simbolo))
         return false;

      entradas[i].simbolo = _simbolo;
      entradas[i].timeFrame = PERIOD_H1;
      entradas[i].periodo = registro.periodo;
      entradas[i].tipoMedia = tipoMediaToENUM(registro.metodo);
      entradas[i].puntosAdicionales = registro.puntosAdicionales;

     }

   DatabaseFinalize(request);

   DatabaseClose(db);

   return true;

  }
//+------------------------------------------------------------------+
