unit AqDrop.DB.Tokenizer;

interface

uses
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Tokenizer;

type
  TAqDBTokenizerDictionaryID = (diOther, diDigits, diCharacters, diPlus, diMinus, diAsterisk, diSlash, diSharp,
    diUnderscore, diSemicolon, diComma, diColon, diLeftParenthesis, diRightParenthesis, diSpace, diDot,
    di10, di13, diSingleQuotes, diDoubleQuotes, diInterrogation, diEqual, diAt, diDollar, diLessThan, diGreaterThan);

  TAqDBTokenizerDictionaries = class
  public const
    MinID = diOther;
    MaxID = diGreaterThan;
  public type
    TDictionaryContent = IAqList<Char>;
  strict private
    class var FDictionaries: IAqDictionary<TAqDBTokenizerDictionaryID, TDictionaryContent>;

    class procedure Initialize;
    class function GetDictionary(pIndex: TAqDBTokenizerDictionaryID): TDictionaryContent; static;
  private
    class procedure _Initialize;
  public
    class property Dictionary[Index: TAqDBTokenizerDictionaryID]: TDictionaryContent read GetDictionary; default;
  end;

  TAqDBTokenType = (ttOther, ttWord, ttInteger, ttReal, ttSpace, ttLineBreak, ttComment, ttMultiplication, ttDivision,
    ttAddition, ttSubtraction, ttLeftParenthesis, ttRightParenthesis, ttComma, ttSemicolon, ttColon, ttString,
    ttParameter, ttNamedParameter, ttEqual, ttDot, ttAt, ttLessThan, ttLessEqualThan, ttGreaterThan,
    ttGreaterEqualThan);

{TODO: colocar no padrão de InstanciaDefault}
  /// <summary>
  ///   Tokenizer para sentenças SQL.
  /// </summary>
  TAqBDTokenizer = class(TAqTokenizer<TAqDBTokenizerDictionaryID, TAqDBTokenType>)
  strict private
    class var FInstance: TAqBDTokenizer;
  private
    class procedure _Finalize;
  public
    constructor Create; override;
    class function GetInstance: TAqBDTokenizer;
  end;

implementation

uses
  AqDrop.Core.Collections,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Automaton,
  AqDrop.Core.Automaton.Text;

{ TAqBDTokenizer }

constructor TAqBDTokenizer.Create;
var
  lTransition: TTokenizerTransition;
  lFinalStateSpace: TTokenizerState;
  lFinalStateWord: TTokenizerState;
  lFinalStateInteger: TTokenizerState;
  lIntermediateStateDot: TTokenizerState;
  lFinalStateReal: TTokenizerState;
  lIntermediateStateLineBreak: TTokenizerState;
  lFinalStateLineBreak: TTokenizerState;
  lFinalStateDivision: TTokenizerState;
  lFinalStateAddition: TTokenizerState;
  lFinalStateSubtraction: TTokenizerState;
  lFinalStateMultiplication: TTokenizerState;
  lFinalStateCommentLine1: TTokenizerState;
  lFinalStateCommentLine2: TTokenizerState;
  lFinalStateCommentLine3: TTokenizerState;
  lIntermediateStateComment1: TTokenizerState;
  lIntermediateStateComment2: TTokenizerState;
  lFinalStateComment: TTokenizerState;
  lFinalStateLeftParenthesis: TTokenizerState;
  lFinalStateRightParenthesis: TTokenizerState;
  lFinalStateComma: TTokenizerState;
  lFinalStateSemicolon: TTokenizerState;
  lIntermediateStateString: TTokenizerState;
  lFinalStateString: TTokenizerState;
  lIntermediateStateDoubleQuotes: TTokenizerState;
  lFinalSteteDoubleQuotes: TTokenizerState;
  lFinalStateColon: TTokenizerState;
  lFinalStateNamedParameter: TTokenizerState;
  lFinalStateParameter: TTokenizerState;
  lFianlStateEqual: TTokenizerState;
  lFinalStateDot: TTokenizerState;
  lFinalStateAt: TTokenizerState;
  lFinalStateLessThan: TTokenizerState;
  lFinalStateLessEqualThan: TTokenizerState;
  lFinalStateGreaterThan: TTokenizerState;
  lFinalStateGreaterEqualThan: TTokenizerState;
  lDictionaryID: TAqDBTokenizerDictionaryID;
begin
  inherited;

  for lDictionaryID := TAqDBTokenizerDictionaries.MinID to TAqDBTokenizerDictionaries.MaxID do
  begin
    Automaton.AddDictionary(lDictionaryID, TAqDBTokenizerDictionaries[lDictionaryID]);
  end;

  lFinalStateSpace := Automaton.AddFinalState(ttSpace);
  lTransition := Automaton.InitialState.AddTransition(lFinalStateSpace);
  lTransition.AddDictionary(diSpace);

  lFinalStateWord := Automaton.AddFinalState(ttWord);
  lTransition := Automaton.InitialState.AddTransition(lFinalStateWord);
  lTransition.AddDictionary(diCharacters);
  lTransition.AddDictionary(diDollar);
  lTransition := lFinalStateWord.AddTransition(lFinalStateWord);
  lTransition.AddDictionary(diCharacters);
  lTransition.AddDictionary(diDigits);
  lTransition.AddDictionary(diUnderscore);
  lTransition.AddDictionary(diDollar);

  lFinalStateInteger := Automaton.AddFinalState(ttInteger);
  lTransition := Automaton.InitialState.AddTransition(lFinalStateInteger);
  lTransition.AddDictionary(diDigits);
  lTransition := lFinalStateInteger.AddTransition(lFinalStateInteger);
  lTransition.AddDictionary(diDigits);
  lIntermediateStateDot := Automaton.AddIntermediateState;
  lTransition := lFinalStateInteger.AddTransition(lIntermediateStateDot);
  lTransition.AddDictionary(diDot);
  lFinalStateReal := Automaton.AddFinalState(ttReal);
  lTransition := lIntermediateStateDot.AddTransition(lFinalStateReal);
  lTransition.AddDictionary(diDigits);
  lTransition := lFinalStateReal.AddTransition(lFinalStateReal);
  lTransition.AddDictionary(diDigits);

  if sLineBreak = #13#10 then
  begin
    lIntermediateStateLineBreak := Automaton.AddIntermediateState;
    Automaton.InitialState.AddTransition(lIntermediateStateLineBreak).AddDictionary(di13);
    lFinalStateLineBreak := Automaton.AddFinalState(ttLineBreak);
    lIntermediateStateLineBreak.AddTransition(lFinalStateLineBreak).AddDictionary(di10);
  end else if sLineBreak = #10 then
  begin
    lIntermediateStateLineBreak := nil;
    lFinalStateLineBreak := Automaton.AddFinalState(ttLineBreak);
    Automaton.InitialState.AddTransition(lFinalStateLineBreak).AddDictionary(di10);
  end else begin
    raise EAqInternal.Create('Line Break not expected.');
  end;

  lFinalStateAddition := Automaton.AddFinalState(ttAddition);
  Automaton.InitialState.AddTransition(lFinalStateAddition).AddDictionary(diPlus);

  lFinalStateSubtraction := Automaton.AddFinalState(ttSubtraction);
  Automaton.InitialState.AddTransition(lFinalStateSubtraction).AddDictionary(diMinus);

  lFinalStateMultiplication := Automaton.AddFinalState(ttMultiplication);
  Automaton.InitialState.AddTransition(lFinalStateMultiplication).AddDictionary(diAsterisk);

  lFinalStateDivision := Automaton.AddFinalState(ttDivision);
  Automaton.InitialState.AddTransition(lFinalStateDivision).AddDictionary(diSlash);

  lFinalStateCommentLine1 := Automaton.AddFinalState(ttComment);
  lFinalStateSubtraction.AddTransition(lFinalStateCommentLine1).AddDictionary(diMinus);
  lFinalStateCommentLine1.AddTransition(lFinalStateCommentLine1).AddDictionary(diOther);
  lFinalStateCommentLine2 := Automaton.AddFinalState(ttComment);

  if sLineBreak = #13#10 then
  begin
    lFinalStateCommentLine1.AddTransition(lFinalStateCommentLine2).AddDictionary(di13);
    lFinalStateCommentLine2.AddTransition(lFinalStateCommentLine1).AddDictionary(diOther);
    lFinalStateCommentLine3 := Automaton.AddFinalState(ttComment);
    lFinalStateCommentLine2.AddTransition(lFinalStateCommentLine3).AddDictionary(di10);
  end else if sLineBreak = #10 then
  begin
    lFinalStateCommentLine1.AddTransition(lFinalStateCommentLine2).AddDictionary(di10);
    lFinalStateCommentLine3 := nil;
  end else begin
    raise EAqInternal.Create('Line break not expected.');
  end;

  lIntermediateStateComment1 := Automaton.AddIntermediateState;
  lFinalStateDivision.AddTransition(lIntermediateStateComment1).AddDictionary(diAsterisk);
  lIntermediateStateComment1.AddTransition(lIntermediateStateComment1).AddDictionary(diOther);
  lIntermediateStateComment2 := Automaton.AddIntermediateState;
  lIntermediateStateComment1.AddTransition(lIntermediateStateComment2).AddDictionary(diAsterisk);
  lIntermediateStateComment2.AddTransition(lIntermediateStateComment2).AddDictionary(diAsterisk);
  lIntermediateStateComment2.AddTransition(lIntermediateStateComment1).AddDictionary(diOther);
  lFinalStateComment := Automaton.AddFinalState(ttComment);
  lIntermediateStateComment2.AddTransition(lFinalStateComment).AddDictionary(diSlash);

  lFinalStateLeftParenthesis := Automaton.AddFinalState(ttLeftParenthesis);
  Automaton.InitialState.AddTransition(lFinalStateLeftParenthesis).AddDictionary(diLeftParenthesis);

  lFinalStateRightParenthesis := Automaton.AddFinalState(ttRightParenthesis);
  Automaton.InitialState.AddTransition(lFinalStateRightParenthesis).AddDictionary(diRightParenthesis);

  lFinalStateComma := Automaton.AddFinalState(ttComma);
  Automaton.InitialState.AddTransition(lFinalStateComma).AddDictionary(diComma);

  lFinalStateSemicolon := Automaton.AddFinalState(ttSemicolon);
  Automaton.InitialState.AddTransition(lFinalStateSemicolon).AddDictionary(diSemicolon);

  lIntermediateStateString := Automaton.AddIntermediateState;
  Automaton.InitialState.AddTransition(lIntermediateStateString).AddDictionary(diSingleQuotes);
  lIntermediateStateString.AddTransition(lIntermediateStateString).AddDictionary(diOther);
  lFinalStateString := Automaton.AddFinalState(ttString);
  lIntermediateStateString.AddTransition(lFinalStateString).AddDictionary(diSingleQuotes);
  lFinalStateString.AddTransition(lIntermediateStateString).AddDictionary(diSingleQuotes);

  lIntermediateStateDoubleQuotes := Automaton.AddIntermediateState;
  Automaton.InitialState.AddTransition(lIntermediateStateDoubleQuotes).AddDictionary(diDoubleQuotes);
  lIntermediateStateDoubleQuotes.AddTransition(lIntermediateStateDoubleQuotes).AddDictionary(diOther);
  lFinalSteteDoubleQuotes := Automaton.AddFinalState(ttString);
  lIntermediateStateDoubleQuotes.AddTransition(lFinalSteteDoubleQuotes).AddDictionary(diDoubleQuotes);
  lFinalSteteDoubleQuotes.AddTransition(lIntermediateStateDoubleQuotes).AddDictionary(diDoubleQuotes);

  lFinalStateColon := Automaton.AddFinalState(ttColon);
  Automaton.InitialState.AddTransition(lFinalStateColon).AddDictionary(diColon);

  lFinalStateNamedParameter := Automaton.AddFinalState(ttNamedParameter);
  lFinalStateColon.AddTransition(lFinalStateNamedParameter).AddDictionary(diCharacters);
  lTransition := lFinalStateNamedParameter.AddTransition(lFinalStateNamedParameter);
  lTransition.AddDictionary(diCharacters);
  lTransition.AddDictionary(diDigits);
  lTransition.AddDictionary(diUnderscore);

  lFinalStateParameter := Automaton.AddFinalState(ttParameter);
  Automaton.InitialState.AddTransition(lFinalStateParameter).AddDictionary(diInterrogation);

  lFianlStateEqual := Automaton.AddFinalState(ttEqual);
  Automaton.InitialState.AddTransition(lFianlStateEqual).AddDictionary(diEqual);

  lFinalStateDot := Automaton.AddFinalState(ttDot);
  Automaton.InitialState.AddTransition(lFinalStateDot).AddDictionary(diDot);

  lFinalStateAt := Automaton.AddFinalState(ttAt);
  Automaton.InitialState.AddTransition(lFinalStateAt).AddDictionary(diAt);

  lFinalStateLessThan := Automaton.AddFinalState(ttLessThan);
  Automaton.InitialState.AddTransition(lFinalStateLessThan).AddDictionary(diLessThan);

  lFinalStateLessEqualThan := Automaton.AddFinalState(ttLessEqualThan);
  lFinalStateLessThan.AddTransition(lFinalStateLessEqualThan).AddDictionary(diEqual);

  lFinalStateGreaterThan := Automaton.AddFinalState(ttGreaterThan);
  Automaton.InitialState.AddTransition(lFinalStateGreaterThan).AddDictionary(diGreaterThan);

  lFinalStateGreaterEqualThan := Automaton.AddFinalState(ttGreaterEqualThan);
  lFinalStateGreaterThan.AddTransition(lFinalStateGreaterEqualThan).AddDictionary(diEqual);
end;

class function TAqBDTokenizer.GetInstance: TAqBDTokenizer;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAqBDTokenizer.Create;
  end;

  Result := FInstance;
end;

class procedure TAqBDTokenizer._Finalize;
begin
  FInstance.Free;
end;

{ TAqDBTokenizerDictionaries }

class function TAqDBTokenizerDictionaries.GetDictionary(pIndex: TAqDBTokenizerDictionaryID): TDictionaryContent;
begin
  Result := FDictionaries.Items[pIndex];
end;

class procedure TAqDBTokenizerDictionaries.Initialize;
  function CreateNewContent(const pID: TAqDBTokenizerDictionaryID): TDictionaryContent;
  begin
    Result := TAqList<Char>.Create;

    FDictionaries.Add(pID, Result);
  end;

var
  lList: IAqList<Char>;
  lChar: Char;
begin
  FDictionaries.Clear;

  CreateNewContent(diOther).Add(#0);

  lList := CreateNewContent(diDigits);
  for lChar := '0' to '9' do
  begin
    lList.Add(lChar);
  end;

  lList := CreateNewContent(diCharacters);
  for lChar := 'A' to 'Z' do
  begin
    lList.Add(lChar);
  end;
  for lChar := 'a' to 'z' do
  begin
    lList.Add(lChar);
  end;

  CreateNewContent(diPlus).Add('+');
  CreateNewContent(diMinus).Add('-');
  CreateNewContent(diAsterisk).Add('*');
  CreateNewContent(diSlash).Add('/');
  CreateNewContent(diSharp).Add('#');
  CreateNewContent(diUnderscore).Add('_');
  CreateNewContent(diSemicolon).Add(';');
  CreateNewContent(diComma).Add(',');
  CreateNewContent(diColon).Add(':');
  CreateNewContent(diLeftParenthesis).Add('(');
  CreateNewContent(diRightParenthesis).Add(')');
  CreateNewContent(diSpace).Add(' ');
  CreateNewContent(diDot).Add('.');
  CreateNewContent(di10).Add(#10);
  CreateNewContent(di13).Add(#13);
  CreateNewContent(diSingleQuotes).Add('''');
  CreateNewContent(diDoubleQuotes).Add('"');
  CreateNewContent(diInterrogation).Add('?');
  CreateNewContent(diEqual).Add('=');
  CreateNewContent(diAt).Add('@');
  CreateNewContent(diDollar).Add('$');
  CreateNewContent(diLessThan).Add('<');
  CreateNewContent(diGreaterThan).Add('>');
end;

class procedure TAqDBTokenizerDictionaries._Initialize;
begin
  FDictionaries := TAqDictionary<TAqDBTokenizerDictionaryID, TDictionaryContent>.Create;

  Initialize;
end;

initialization
  TAqDBTokenizerDictionaries._Initialize;

finalization
  TAqBDTokenizer._Finalize;

end.

