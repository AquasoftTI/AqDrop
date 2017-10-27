unit AqDrop.DB.FD.TypeMapping;

interface

uses
  System.Classes,
{$IF CompilerVersion >= 28}
  FireDAC.Stan.Intf,
{$ENDIF}
{$IF CompilerVersion >= 26}
  FireDAC.Stan.Param,
  FireDAC.Comp.Client;
{$ELSE}
  uADStanParam,
  uADCompClient;
{$ENDIF}


type
{$IF CompilerVersion >= 26}
  TAqFDMappedParam = TFDParam;
  TAqFDMappedQuery = TFDQuery;
  TAqFDMappedConnection = TFDConnection;
{$ELSE}
  TAqFDMappedParam = TADParam;
  TAqFDMappedQuery = TADQuery;
  TAqFDMappedConnection = TADConnection;
{$ENDIF}

{$IF CompilerVersion >= 28}
  TAqFDMappedConnectionParameters = TFDConnectionDefParams;
{$ELSE}
  TAqFDMappedConnectionParameters = TStrings;
{$ENDIF}


implementation

end.
