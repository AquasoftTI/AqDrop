unit AqDrop.Core.Helpers.Exception;

interface

uses
  System.SysUtils,
  AqDrop.Core.Helpers;

type
  TExceptionHelper = class helper for Exception
  public
    procedure ForThisAndInnerExceptions(const pHandler: TProc<Exception>);
    function ConcatFullMessage(const pBetweenMessages: string = string.LineBreak): string;
  end;

implementation

{ TExceptionHelper }

function TExceptionHelper.ConcatFullMessage(const pBetweenMessages: string): string;
var
  lResult: string;
begin
  lResult := '';

  ForThisAndInnerExceptions(
    procedure(E: Exception)
    begin
      if not lResult.IsEmpty then
      begin
        lResult := lResult + pBetweenMessages;
      end;

      lResult := lResult + E.Message;
    end);

  Result := lResult;
end;

procedure TExceptionHelper.ForThisAndInnerExceptions(const pHandler: TProc<Exception>);
var
  lException: Exception;
begin
  lException := Self;

  while Assigned(lException) do
  begin
    pHandler(lException);

    lException := lException.InnerException;
  end;
end;

end.
