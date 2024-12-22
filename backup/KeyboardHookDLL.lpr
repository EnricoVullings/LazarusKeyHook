library KeyboardHookDLL;

{$mode objfpc}{$H+}


uses
  Windows, Messages, SysUtils, Classes;

const
  WH_KEYBOARD_LL = 13;

Type
  TMainCallBack = procedure (nCode: Integer; wParam: WPARAM; lParam: LPARAM); stdcall;

var
  HookHandle     : HHOOK  = 0;
  LastMessage    : String = '';
  CallbackToMain : TMainCallBack = nil;


function KeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  if nCode = HC_ACTION then
  begin

    If CallBackToMain <> nil
    then
      CallBackToMain( nCode, wParam, lParam );
      //LastMessage := IntToStr( nCode ) + ' ' + IntToStr( wParam ) + ' ' + IntToStr( lParam );
    end; // If CallBackToMain <>nil

    // Hier kun je je eigen logica toevoegen
  end;
  Result := CallNextHookEx(HookHandle, nCode, wParam, lParam);
end;

procedure InstallHook; stdcall;
begin
  HookHandle := SetWindowsHookEx( WH_KEYBOARD_LL, @KeyboardProc, HInstance, 0);
end;

procedure UninstallHook; stdcall;
begin
  if HookHandle <> 0 then
  begin
    UnhookWindowsHookEx(HookHandle);
    HookHandle := 0;
  end;
end;

Procedure GetLastMsg( Var LastMsg : String ); stdcall;
Begin
  LastMsg := LastMessage;
end;

Procedure SetMainCallBack( MainCallBack : TMainCallBack ); stdcall;
Begin
  CallbackToMain := MainCallBack;
end;

exports
  InstallHook,
  UninstallHook,
  GetLastMsg,
  SetMainCallBack;

begin
end.

