unit AqDrop.DB.ORM.Manager;

interface

uses
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.DB.Types,
  AqDrop.DB.Connection,
  AqDrop.DB.SQL.Intf;

type
  TAqDBORMManager = class
  strict private
    FConnection: TAqDBConnection;

    procedure FillParametersWithObjectValues(pParameters: IAqDBParameters; const pObject: TObject);
  public
    constructor Create(const pConnection: TAqDBConnection);

    function BuildSelect(const pClass: TClass): IAqDBSQLSelect;
    function BuildInserts(const pClass: TClass): IAqResultList<IAqDBSQLInsert>;
    function BuildUpdates(const pClass: TClass): IAqResultList<IAqDBSQLUpdate>;
    function BuildDeletes(const pClass: TClass): IAqResultList<IAqDBSQLDelete>;

    function Get<T: class, constructor>(out pList: IAqResultList<T>): Boolean; overload;
    function Get<T: class, constructor>(pSelect: IAqDBSQLSelect; out pList: IAqResultList<T>): Boolean; overload;
    function Get<T: class, constructor>(pSelect: string; out pList: IAqResultList<T>): Boolean; overload;

    procedure Add(const pObject: TObject); overload;
    procedure Add(const pInserts: IAqReadList<IAqDBSQLInsert>; const pObject: TObject); overload;
    procedure Add(const pInsert: IAqDBSQLInsert; const pObject: TObject); overload;

    procedure Update(const pObject: TObject); overload;
    procedure Update(const pUpdates: IAqReadList<IAqDBSQLUpdate>; const pObject: TObject); overload;
    procedure Update(const pUpdate: IAqDBSQLUpdate; const pObject: TObject); overload;

    procedure Post(const pObject: TObject);

    procedure Delete(const pObject: TObject; const pFreeObject: Boolean = True); overload;
    procedure Delete(const pDeletes: IAqReadList<IAqDBSQLDelete>; const pObject: TObject); overload;
    procedure Delete(const pDelete: IAqDBSQLDelete; const pObject: TObject); overload;

    function ExecuteWithObject(const pSQLCommand: string; const pObject: TObject): Int64;

    property Connection: TAqDBConnection read FConnection;
  end;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections,
  AqDrop.DB.ORM.Reader,
  AqDrop.DB.SQL, 
  AqDrop.DB.ORM.Attributes, System.Rtti;

{ TAqDBORMManager }

constructor TAqDBORMManager.Create(const pConnection: TAqDBConnection);
begin
  FConnection := pConnection;
end;

procedure TAqDBORMManager.Delete(const pDeletes: IAqReadList<IAqDBSQLDelete>; const pObject: TObject);
var
  lDelete: IAqDBSQLDelete;
begin
  FConnection.StartTransaction;

  try
    for lDelete in pDeletes do
    begin
      Delete(lDelete, pObject);
    end;

    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

procedure TAqDBORMManager.Delete(const pDelete: IAqDBSQLDelete; const pObject: TObject);
begin
  ExecuteWithObject(FConnection.Mapper.SolveDelete(pDelete), pObject);
end;

procedure TAqDBORMManager.Delete(const pObject: TObject; const pFreeObject: Boolean);
begin
  Delete(BuildDeletes(pObject.ClassType), pObject);

  if pFreeObject then
  begin
    pObject.Free;
  end;
end;

procedure TAqDBORMManager.FillParametersWithObjectValues(pParameters: IAqDBParameters; const pObject: TObject);
var
  lI: Int32;
  lColumn: TAqDBORMColumn;
  lORM: TAqDBORM;
begin
  lORM := TAqDBORMReader.GetORM(pObject.ClassType);

  for lI := 0 to pParameters.Count - 1 do
  begin
    if lORM.GetColumn(pParameters[lI].Name, lColumn) then
    begin
      lColumn.SetDBValue(pObject, pParameters[lI]);
    end;
  end;
end;

function TAqDBORMManager.Get<T>(out pList: IAqResultList<T>): Boolean;
begin
  Result := Get<T>(BuildSelect(T), pList);
end;

function TAqDBORMManager.Get<T>(pSelect: IAqDBSQLSelect; out pList: IAqResultList<T>): Boolean;
begin
  Result := Get<T>(FConnection.Mapper.SolveSelect(pSelect), pList);
end;

function TAqDBORMManager.Get<T>(pSelect: string; out pList: IAqResultList<T>): Boolean;
var
  lORM: TAqDBORM;
  lReader: IAqDBReader;
  lList: TAqResultList<T>;
  lObject: T;
  lI: Int32;
  lColumn: TAqDBORMColumn;
begin
  Result := False;
  lList := nil;

  try
    lReader := FConnection.OpenQuery(pSelect);

    while lReader.Next do
    begin
      if not Result then
      begin
        lORM := TAqDBORMReader.GetORM(T);
        Result := True;
        lList := TAqResultList<T>.Create(True);
      end;

      lList.Add(T.Create);
      lObject := lList.Last;

      for lI := 0 to lReader.Count - 1 do
      begin
        if lORM.GetColumn(lReader[lI].Name, lColumn) then
        begin
          lColumn.SetObjectValue(lObject, lReader[lI]);
        end;
      end;
    end;
  except
    lList.Free;
    raise;
  end;

  if Result then
  begin
    pList := lList;
  end;
end;

procedure TAqDBORMManager.Add(const pObject: TObject);
begin
  Add(BuildInserts(pObject.ClassType), pObject);
end;

procedure TAqDBORMManager.Post(const pObject: TObject);
var
  lInserts: IAqResultList<IAqDBSQLInsert>;
  lUpdates: IAqResultList<IAqDBSQLUpdate>;
  lI: Int32;
  lSelect: IAqDBSQLSelect;
  lReader: IAqDBReader;
begin
  lInserts := BuildInserts(pObject.ClassType);
  lUpdates := BuildUpdates(pObject.ClassType);

  if lInserts.Count <> lUpdates.Count then
  begin
    raise EAqInternal.Create('Inserts and Updates of ' + pObject.ClassName + ' has diferent counts.');
  end;

  FConnection.StartTransaction;

  try
    for lI := 0 to lUpdates.Count - 1 do
    begin
      lSelect := TAqDBSQLSelect.Create(lUpdates[lI].Table.Name);
      lSelect.AddColumn(TAqDBSQLNumericConstant.Create(1));
      lSelect.Condition := lUpdates[lI].Condition;
      lSelect.Limit := 1;

      lReader := FConnection.OpenQuery(lSelect,
        procedure(pParameters: IAqDBParameters)
        begin
          FillParametersWithObjectValues(pParameters, pObject);
        end);

      if lReader.Next then
      begin
        Update(lUpdates[lI], pObject);
      end else begin
        Add(lInserts[lI], pObject);
      end;
    end;

    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

procedure TAqDBORMManager.Update(const pUpdates: IAqReadList<IAqDBSQLUpdate>; const pObject: TObject);
var
  lUpdate: IAqDBSQLUpdate;
begin
  FConnection.StartTransaction;

  try
    for lUpdate in pUpdates do
    begin
      Update(lUpdate, pObject);
    end;
    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

procedure TAqDBORMManager.Update(const pUpdate: IAqDBSQLUpdate; const pObject: TObject);
begin
  ExecuteWithObject(FConnection.Mapper.SolveUpdate(pUpdate), pObject);
end;

procedure TAqDBORMManager.Update(const pObject: TObject);
begin
  Update(BuildUpdates(pObject.ClassType), pObject);
end;

procedure TAqDBORMManager.Add(const pInsert: IAqDBSQLInsert; const pObject: TObject);
var
  lORM: TAqDBORM;
  lHasAutoIncrementColumn: Boolean;
  lTable: TAqDBORMTable;
  lAutoIncrementColumn: TAqDBORMColumn;
  lGeneratorName: string;
begin
  lORM := TAqDBORMReader.GetORM(pObject.ClassType);

  lHasAutoIncrementColumn := lORM.GetTable(pInsert.Table.Name, lTable) and
    lTable.HasAutoIncrementColumn(lAutoIncrementColumn);

  FConnection.StartTransaction;

  try
    if lHasAutoIncrementColumn and (FConnection.AutoIncrementType = TAqDBAutoIncrementType.aiGenerator) then
    begin
      if Assigned(lAutoIncrementColumn.Attribute) and (lAutoIncrementColumn.Attribute is AqAutoIncrementColumn) and
        AqAutoIncrementColumn(lAutoIncrementColumn.Attribute).IsGeneratorDefined then
      begin
        lGeneratorName := AqAutoIncrementColumn(lAutoIncrementColumn.Attribute).GeneratorName;
      end else begin
        lGeneratorName := FConnection.Mapper.GetGeneratorName(lTable.Name);
      end;

      lAutoIncrementColumn.SetObjectValue(pObject, TValue.From<Int64>(FConnection.GetAutoIncrement(lGeneratorName)));
    end;

    ExecuteWithObject(FConnection.Mapper.SolveInsert(pInsert), pObject);

    if lHasAutoIncrementColumn and (FConnection.AutoIncrementType = TAqDBAutoIncrementType.aiAutoIncrement) then
    begin
      lAutoIncrementColumn.SetObjectValue(pObject, TValue.From<Int64>(FConnection.GetAutoIncrement));
    end;

    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

procedure TAqDBORMManager.Add(const pInserts: IAqReadList<IAqDBSQLInsert>; const pObject: TObject);
var
  lInsert: IAqDBSQLInsert;
begin
  FConnection.StartTransaction;

  try
    for lInsert in pInserts do
    begin
      Add(lInsert, pObject);
    end;
    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

function TAqDBORMManager.BuildDeletes(const pClass: TClass): IAqResultList<IAqDBSQLDelete>;
var
  lORM: TAqDBORM;
  lDeletes: TAqResultList<IAqDBSQLDelete>;
  lPKs: TAqList<TAqDBORMColumn>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lFirstCondition: TAqDBSQLComparisonCondition;
  lComposedCondition: TAqDBSQLComposedCondition;

  function CreateCondition(const pColumnName: string): TAqDBSQLComparisonCondition;
  begin
    Result := TAqDBSQLComparisonCondition.Create(TAqDBSQLColumn.Create(pColumnName),
      TAqDBSQLComparison.cpEqual, TAqDBSQLParameter.Create(pColumnName));
  end;

  procedure AddCondition(const pColumnName: string);
  begin
    if not Assigned(lFirstCondition) then
    begin
      lFirstCondition := CreateCondition(pColumnName);
    end else begin
      if not Assigned(lComposedCondition) then
      begin
        lComposedCondition := TAqDBSQLComposedCondition.Create(lFirstCondition);
      end;

      lComposedCondition.AddCondition(TAqDBSQLBooleanOperator.boAnd, CreateCondition(pColumnName));
    end;
  end;

  procedure AddDelete(pTable: TAqDBORMTable<AqTable>);
  var
    lColumn: TAqDBORMColumn;
    lDelete: IAqDBSQLDelete;
  begin
    lFirstCondition := nil;
    lComposedCondition := nil;

    lDelete := TAqDBSQLDelete.Create(pTable.Name);

    if TAqDBTableMappingProperty.tmpInheritPKs in pTable.Attribute.MappingProperties then
    begin
      for lColumn in lPKs do
      begin
        AddCondition(lColumn.Name);
      end;
    end;

    for lColumn in pTable.Columns do
    begin
      if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
      begin
        AddCondition(lColumn.Name);
        lPKs.Add(lColumn);
      end;
    end;

    if Assigned(lComposedCondition) then
    begin
      lDelete.Condition := lComposedCondition;
    end else if Assigned(lFirstCondition) then
    begin
      lDelete.Condition := lFirstCondition;
    end;

    lDeletes.Insert(0, lDelete);
  end;
begin
  lORM := TAqDBORMReader.GetORM(pClass);

  lDeletes := TAqResultList<IAqDBSQLDelete>.Create;

  try
    lPKs := TAqList<TAqDBORMColumn>.Create;

    try
      AddDelete(lORM.MainTable);

      if lORM.HasSpecializations then
      begin
        for lSpecialization in lORM.Specializations do
        begin
          AddDelete(TAqDBORMTable<AqTable>(lSpecialization));
        end;
      end;
    finally
      lPKs.Free;
    end;
  except
    lDeletes.Free;
    raise;
  end;

  Result := lDeletes;
end;

function TAqDBORMManager.BuildInserts(const pClass: TClass): IAqResultList<IAqDBSQLInsert>;
var
  lORM: TAqDBORM;
  lInserts: TAqResultList<IAqDBSQLInsert>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lPKs: TAqList<TAqDBORMColumn>;

  procedure AddInsert(const pTable: TAqDBORMTable<AqTable>);
  var
    lInsert: IAqDBSQLInsert;
    lColumn: TAqDBORMColumn;
  begin
    lInsert := TAqDBSQLInsert.Create(pTable.Name);

    if TAqDBTableMappingProperty.tmpInheritPKs in pTable.Attribute.MappingProperties then
    begin
      for lColumn in lPKs do
      begin
        lInsert.AddAssignment(TAqDBSQLColumn.Create(lColumn.Name), TAqDBSQLParameter.Create(lColumn.Name));
      end;
    end;

    for lColumn in pTable.Columns do
    begin
      if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
      begin
        lPKs.Add(lColumn);
      end;

      if not Assigned(lColumn.Attribute) or not lColumn.Attribute.AutoIncrement then
      begin
        lInsert.AddAssignment(TAqDBSQLColumn.Create(lColumn.Name), TAqDBSQLParameter.Create(lColumn.Name));
      end;
    end;

    lInserts.Add(lInsert);
  end;
begin
  lORM := TAqDBORMReader.GetORM(pClass);

  lInserts := TAqResultList<IAqDBSQLInsert>.Create;

  try
    lPKs := TAqList<TAqDBORMColumn>.Create;

    try
      AddInsert(lORM.MainTable);

      if lORM.HasSpecializations then
      begin
        for lSpecialization in lORM.Specializations do
        begin
          AddInsert(TAqDBORMTable<AqTable>(lSpecialization));
        end;
      end;
    finally
      lPKs.Free;
    end;
  except
    lInserts.Free;
    raise;
  end;

  Result := lInserts;
end;

function TAqDBORMManager.BuildSelect(const pClass: TClass): IAqDBSQLSelect;
var
  lSelect: TAqDBSQLSelect;
  lORM: TAqDBORM;
  lColumn: TAqDBORMColumn;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lCondition: TAqDBSQLComposedCondition;
  lLink: TAqDBLink;
  lMasterSource: TAqDBSQLSource;
  lDetail: TAqDBSQLSource;

  procedure AddLinkCondition(const pCondition: TAqDBSQLCondition);
  begin
    if not Assigned(lCondition) then
    begin
      lCondition := TAqDBSQLComposedCondition.Create(pCondition);
    end else begin
      lCondition.AddCondition(TAqDBSQLBooleanOperator.boAnd, pCondition);
    end;
  end;
begin
  lSelect := nil;
  try
    lORM := TAqDBORMReader.GetORM(pClass);

    lMasterSource := TAqDBSQLTable.Create(lORM.MainTable.Name);
    lSelect := TAqDBSQLSelect.Create(lMasterSource);

    for lColumn in lORM.MainTable.Columns do
    begin
      lSelect.AddColumn(lColumn.Name);
    end;

    if lORM.HasSpecializations then
    begin
      for lSpecialization in lORM.Specializations do
      begin
        if lSpecialization.Attribute.Links.Count = 0 then
        begin
          raise EAqInternal.Create('The specialization has no links.');
        end;

        lDetail := TAqDBSQLTable.Create(lSpecialization.Name);
        lCondition := nil;

        for lLink in lSpecialization.Attribute.Links do
        begin
          AddLinkCondition(TAqDBSQLComparisonCondition.Create(
            TAqDBSQLColumn.Create(lLink.MasterKey, lMasterSource),
            TAqDBSQLComparison.cpEqual,
            TAqDBSQLColumn.Create(lLink.ForeignKey, lDetail)));
        end;

        lSelect.AddJoin(TAqDBSQLJoinType.jtInnerJoin, lDetail, lCondition);

        for lColumn in lSpecialization.Columns do
        begin
          lSelect.AddColumn(lColumn.Name, '', lDetail);
        end;

        lMasterSource := lDetail;
      end;
    end;
  except
    on E: Exception do
    begin
      lSelect.Free;
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to build the select for the ' +
        pClass.ClassName + ' class.'));
    end;
  end;

  Result := lSelect;
end;

function TAqDBORMManager.BuildUpdates(const pClass: TClass): IAqResultList<IAqDBSQLUpdate>;
var
  lORM: TAqDBORM;
  lUpdates: TAqResultList<IAqDBSQLUpdate>;
  lPKs: TAqList<TAqDBORMColumn>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lFirstCondition: TAqDBSQLComparisonCondition;
  lComposedCondition: TAqDBSQLComposedCondition;

  function CreateCondition(const pColumnName: string): TAqDBSQLComparisonCondition;
  begin
    Result := TAqDBSQLComparisonCondition.Create(TAqDBSQLColumn.Create(pColumnName),
      TAqDBSQLComparison.cpEqual, TAqDBSQLParameter.Create(pColumnName));
  end;

  procedure AddCondition(const pColumnName: string);
  begin
    if not Assigned(lFirstCondition) then
    begin
      lFirstCondition := CreateCondition(pColumnName);
    end else begin
      if not Assigned(lComposedCondition) then
      begin
        lComposedCondition := TAqDBSQLComposedCondition.Create(lFirstCondition);
      end;

      lComposedCondition.AddCondition(TAqDBSQLBooleanOperator.boAnd, CreateCondition(pColumnName));
    end;
  end;

  procedure AddUpdate(pTable: TAqDBORMTable<AqTable>);
  var
    lColumn: TAqDBORMColumn;
    lUpdate: IAqDBSQLUpdate;
  begin
    lFirstCondition := nil;
    lComposedCondition := nil;

    lUpdate := TAqDBSQLUpdate.Create(pTable.Name);

    if TAqDBTableMappingProperty.tmpInheritPKs in pTable.Attribute.MappingProperties then
    begin
      for lColumn in lPKs do
      begin
        AddCondition(lColumn.Name);
      end;
    end;

    for lColumn in pTable.Columns do
    begin
      if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
      begin
        AddCondition(lColumn.Name);
        lPKs.Add(lColumn);
      end else begin
        lUpdate.AddAssignment(TAqDBSQLColumn.Create(lColumn.Name), TAqDBSQLParameter.Create(lColumn.Name));
      end;
    end;

    if Assigned(lComposedCondition) then
    begin
      lUpdate.Condition := lComposedCondition;
    end else if Assigned(lFirstCondition) then
    begin
      lUpdate.Condition := lFirstCondition;
    end;

    lUpdates.Add(lUpdate);
  end;
begin
  lORM := TAqDBORMReader.GetORM(pClass);

  lUpdates := TAqResultList<IAqDBSQLUpdate>.Create;

  try
    lPKs := TAqList<TAqDBORMColumn>.Create;

    try
      AddUpdate(lORM.MainTable);

      if lORM.HasSpecializations then
      begin
        for lSpecialization in lORM.Specializations do
        begin
          AddUpdate(TAqDBORMTable<AqTable>(lSpecialization));
        end;
      end;
    finally
      lPKs.Free;
    end;
  except
    lUpdates.Free;
    raise;
  end;

  Result := lUpdates;
end;

function TAqDBORMManager.ExecuteWithObject(const pSQLCommand: string; const pObject: TObject): Int64;
begin
  Result := FConnection.ExecuteCommand(pSQLCommand,
    procedure(pParameters: IAqDBParameters)
    begin
      FillParametersWithObjectValues(pParameters, pObject);
    end);
end;

end.
