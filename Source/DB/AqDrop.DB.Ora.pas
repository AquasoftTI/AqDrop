unit AqDrop.DB.Ora;

interface

uses
  AqDrop.DB.SQL.Intf,
  AqDrop.DB.Adapter;

type
  TAqDBOraSQLSolver = class(TAqDBSQLSolver)
  strict protected
    function SolveLimit(pSelect: IAqDBSQLSelect): string; override;
    function SolveOffset(pSelect: IAqDBSQLSelect): string; override;
    function SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string; override;
    function SolveSelectBody(pSelect: IAqDBSQLSelect): string; override;
    function SolveAlias(pAliasable: IAqDBSQLAliasable; const pQuoteAlias: Boolean): string; override;
    function SolveLikeLeftValue(pLeftValue: IAqDBSQLValue): string; override;
    function SolveLikeRightValue(pRightValue: IAqDBSQLValue): string; override;
  public
    function SolveGeneratorName(const pTableName, pFieldName: string): string; override;
    function GetAutoIncrementQuery(const pGeneratorName: string): string; override;
  end;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Helpers;

{ TAqDBOraSQLSolver }

function TAqDBOraSQLSolver.GetAutoIncrementQuery(const pGeneratorName: string): string;
begin
  Result := Format('select %s.nextval from dual', [pGeneratorName]);
end;

function TAqDBOraSQLSolver.SolveAlias(pAliasable: IAqDBSQLAliasable; const pQuoteAlias: Boolean): string;
var
  lAlias: string;
  lI: Int32;
  lHasSpecialChars: Boolean;
begin
  lHasSpecialChars := False;
  if pAliasable.IsAliasDefined then
  begin
    lAlias := pAliasable.Alias.ToUpper;
    lI := 0;
    while not lHasSpecialChars and (lI < lAlias.Length) do
    begin
      lHasSpecialChars := not CharInSet(lAlias.Chars[lI], ['A'..'Z', '0'..'9']);
      Inc(lI);
    end;
  end;

  Result := inherited SolveAlias(pAliasable, lHasSpecialChars);
end;

function TAqDBOraSQLSolver.SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string;
begin
  if pConstant.Value then
  begin
    Result := '1';
  end else begin
    Result := '0';
  end;

  Result := Result.Quote;
end;

function TAqDBOraSQLSolver.SolveGeneratorName(const pTableName, pFieldName: string): string;
begin
  Result := Format('%s_SEQ', [pTableName]);
end;

function TAqDBOraSQLSolver.SolveLikeLeftValue(pLeftValue: IAqDBSQLValue): string;
begin
  Result := Format('upper(%s)', [inherited]);
end;

function TAqDBOraSQLSolver.SolveLikeRightValue(pRightValue: IAqDBSQLValue): string;
begin
  Result := Format('upper(%s)', [inherited]);
end;

function TAqDBOraSQLSolver.SolveLimit(pSelect: IAqDBSQLSelect): string;
var
  lLimit: UInt32;
begin
  if pSelect.IsLimitDefined then
  begin
    lLimit := pSelect.Limit;

    if pSelect.IsOffsetDefined then
    begin
      Inc(lLimit, pSelect.Offset);
    end;

    pSelect.CustomizeCondition.AddColumnLessEqualThan('innerrownum', lLimit);
  end;

  Result := '';
end;

function TAqDBOraSQLSolver.SolveOffset(pSelect: IAqDBSQLSelect): string;
begin
  if pSelect.IsOffsetDefined then
  begin
    pSelect.CustomizeCondition.AddColumnGreaterThan('innerrownum', pSelect.Offset);
  end;

  Result := '';
end;

function TAqDBOraSQLSolver.SolveSelectBody(pSelect: IAqDBSQLSelect): string;
var
  lInnserSelect: IAqDBSQLSelect;
begin
  if pSelect.IsLimitDefined or pSelect.IsOffsetDefined then
  begin
    if pSelect.Columns.Count = 0 then
    begin
      pSelect.AddColumn('*', '', pSelect.Source);
    end;

    pSelect.AddColumn('rownum', 'innerrownum');

    pSelect.Encapsulate;

    lInnserSelect := pSelect.Source.GetAsSelect;

    pSelect.Limit := lInnserSelect.Limit;
    pSelect.Offset := lInnserSelect.Offset;
    lInnserSelect.ClearLimit;
    lInnserSelect.ClearOffset;

    SolveOffset(pSelect);
    SolveLimit(pSelect);
  end;

  Result := inherited;
end;

end.
