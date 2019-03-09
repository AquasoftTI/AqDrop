unit AqDrop.DB.IB;

interface

uses
  AqDrop.DB.Adapter,
  AqDrop.DB.SQL.Intf;

type
  TAqDBIBSQLSolver = class(TAqDBSQLSolver)
  strict protected
    function SolveLimit(pSelect: IAqDBSQLSelect): string; override;
    function SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string; override;
  public
    function SolveSelect(pSelect: IAqDBSQLSelect): string; override;
    function SolveGeneratorName(const pTableName, pFieldName: string): string; override;
    function GetAutoIncrementQuery(const pGeneratorName: string): string; override;
  end;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers;

{ TAqDBIBSQLSolver }

function TAqDBIBSQLSolver.GetAutoIncrementQuery(const pGeneratorName: string): string;
begin
  Result := Format('select GEN_ID(%s, 1) from RDB$DATABASE', [pGeneratorName]);
end;

function TAqDBIBSQLSolver.SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string;
begin
  if pConstant.Value then
  begin
    Result := 'True';
  end else begin
    Result := 'False';
  end;
end;

function TAqDBIBSQLSolver.SolveGeneratorName(const pTableName, pFieldName: string): string;
begin
  Result := Format('GEN_%s_%s', [pTableName, pFieldName]);
end;

function TAqDBIBSQLSolver.SolveLimit(pSelect: IAqDBSQLSelect): string;
begin
  if pSelect.IsOffsetDefined then
  begin
    if not pSelect.IsLimitDefined then
    begin
      raise EAqInternal.Create('Offset defined for a non limited select on IB.');
    end;
    Result := ' rows ' + (pSelect.Offset + 1).ToString + ' to ' + (pSelect.Offset + pSelect.Limit).ToString;
  end else if pSelect.IsLimitDefined then
  begin
    Result := ' rows ' + pSelect.Limit.ToString;
  end else begin
    Result := '';
  end;
end;

function TAqDBIBSQLSolver.SolveSelect(pSelect: IAqDBSQLSelect): string;
begin
  Result := inherited + SolveLimit(pSelect);
end;

end.
