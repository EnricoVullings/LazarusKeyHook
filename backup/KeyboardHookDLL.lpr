library KeyboardHookDLL;

{$mode objfpc}{$H+}


uses
  Windows, Messages, SysUtils, Classes;

const
  WH_KEYBOARD_LL = 13;

var
  HookHandle: HHOOK = 0;
  LastMessage : String = '';

function KeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  if nCode = HC_ACTION then
  begin
    LastMessage := IntToStr( nCode ) + ' ' + IntToStr( wParam ) + ' ' + IntToStr( lParam );
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

exports
  InstallHook,
  UninstallHook;

begin
end.

