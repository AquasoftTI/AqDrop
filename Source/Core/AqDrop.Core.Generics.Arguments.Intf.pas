unit AqDrop.Core.Generics.Arguments.Intf;

interface

type
  IAqArguments<TArg1, TArg2> = interface
    ['{DFAACC9A-12BB-4A32-9A9F-C7AC680077C9}']

    function GetArg1: TArg1;
    function GetArg2: TArg2;

    property Arg1: TArg1 read GetArg1;
    property Arg2: TArg2 read GetArg2;
  end;

implementation

end.
