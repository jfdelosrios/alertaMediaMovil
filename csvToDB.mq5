//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   string filename = "mediaAlerta";
//--- Creamos o abrimos la base de datos en la carpeta general del terminal
   int db = DatabaseOpen(
               filename,
               DATABASE_EXPORT_COMMON_FOLDER|DATABASE_OPEN_CREATE|DATABASE_OPEN_READWRITE
            );

   if(db == INVALID_HANDLE)
     {
      Print("DB: ", filename, " open failed with code ", GetLastError());
      return;
     }

   if(DatabaseTableExists(
         db,      // manejador de base de datos recibido en DatabaseOpen
         filename
      ))
     {
      Print("La tabla " + filename + " ya existe.");
      DatabaseClose(db);
      return;
     }


   if(-1 == DatabaseImport(
         db,                     // manejador de base de datos recibido en DatabaseOpen
         "Media",            // nombre del recuadro para insertar los datos
         filename+".csv",     // nombre del archivo para importar los datos
         DATABASE_EXPORT_COMMON_FOLDER|DATABASE_IMPORT_HEADER, // combinación de banderas
         ";",                    // separador de datos
         0,                      // cuantas primeras líneas se omiten
         ""
      ))
     {
      if(_LastError == 5131)
        {
         Print("No se pudo crear la tabla, "+ IntegerToString(_LastError));
        }
      else
        {
         Print("-1 == DatabaseImport , "+ IntegerToString(_LastError));
        }
      DatabaseClose(db);
      return;
     }

//--- cerramos la base de datos
   DatabaseClose(db);
      Print("Pude crear ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\", filename, ".sqlite");
  }
//+------------------------------------------------------------------+
