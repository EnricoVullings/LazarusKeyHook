unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Messages, Windows; // Two extra units

const
  WH_KEYBOARD_LL = 13; // Keyboard hook constant
  WM_KEYDOWN = $0100;  // KeyDown message

type
  TInstallHook     = procedure; stdcall;
  TUninstallHook   = procedure; stdcall;
  TGetLastMsg      = Procedure ( var LastMsg : string ); StdCall;
  TMainCallBack    = procedure (nCode: Integer; wParam: WPARAM; lParam: LPARAM); stdcall;
  TSetMainCallBack = Procedure ( MainCallBack : TMainCallBack ); stdcall;

type KBDLLHOOKSTRUCT =
     record
        vkCode: DWORD;
        scanCode: DWORD;
        flags: DWORD;
        time: DWORD;
        dwExtraInfo:
        ULONG_PTR;
     end;
     PKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;


  { TForm1 }
  TForm1 = class(TForm)
    Label1: TLabel;
    ListBox1: TListBox;
    PlaceHookBtn: TButton;

    Button1: TButton;
    UnHookBtn: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PlaceHookBtnClick(Sender: TObject);
    procedure UnHookBtnClick(Sender: TObject);
  private
    HookHandle : HHOOK; // Hook address

    Procedure LoadDLL;
    Procedure UnLoadDLL;

  public

  end;



var
  Form1           : TForm1;
  DLLHandle       : THandle;
  InstallHook     : TInstallHook;
  UninstallHook   : TUninstallHook;
  LastMsg         : TGetLastMsg;
  SetMainCallBack : TSetMainCallBack;

implementation

{$R *.lfm}

{ TForm1 }

procedure MainCallBack(nCode: Integer; wParam: WPARAM; lParam: LPARAM); stdcall;
Var kbStruct : PKBDLLHOOKSTRUCT;

Begin
  //Form1.ListBox1.Items.Insert(0, IntToStr( nCode ) + ' ' + IntToSTr( wParam )+ ' '+ IntToSTr( Lparam ) );

  if (nCode = HC_ACTION)
     then begin
       kbStruct := PKBDLLHOOKSTRUCT(lParam);
       Form1.ListBox1.Items.Insert(0, IntToStr( kbStruct^.Time )+ ' '+ IntToStr( kbStruct^.VKCode )+ ' '+IntToStr( kbStruct^.ScanCode )+ ' ');
       // Hier kun je de toetsenbordgebeurtenissen verwerken end;
  end;

end;


procedure TForm1.LoadDLL;
begin
  DLLHandle := LoadLibrary('KeyboardHookDLL.dll');
  if DLLHandle <> 0 then
  begin
    InstallHook     := TInstallHook    ( GetProcAddress ( DLLHandle, 'InstallHook'     ));
    UninstallHook   := TUninstallHook  ( GetProcAddress ( DLLHandle, 'UninstallHook'   ));
    LastMsg         := TGetLastMsg     ( GetProcAddress ( DLLHandle, 'GetLastMsg'      ));
    SetMainCallBack := TSetMainCallBack( GetProcAddress ( DLLHandle, 'SetMainCallBack' ));

    if Assigned(InstallHook) and Assigned(UninstallHook)   and
       Assigned(LastMsg)     and Assigned(SetMainCallback) then
    begin
      SetMainCallBack( @MainCallBack );
      InstallHook;
    end
    else
    begin
      ShowMessage('Kan functies niet vinden in DLL.');
    end;
  end
  else
  begin
    ShowMessage('Kan DLL niet laden.');
  end;
end;

procedure TForm1.UnloadDLL;
begin
  if DLLHandle <> 0 then
  begin
    UninstallHook;
    FreeLibrary(DLLHandle);
    DLLHandle := 0;
  end;
end;




procedure TForm1.Button1Click(Sender: TObject);
begin
  Self.close;
end;

procedure TForm1.Button2Click(Sender: TObject);
Var Line : string;
begin
  LastMsg( Line );
  Self.ListBox1.Items.Insert(0, Line );
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Self.ListBox1.Clear;
end;


procedure TForm1.PlaceHookBtnClick(Sender: TObject);
begin
    Self.LoadDLL;
end;

procedure TForm1.UnHookBtnClick(Sender: TObject);
begin
  Self.UnloadDLL;
end;

end.

