@echo off
setlocal

set REPO=%~dp0
set REPO=%REPO:~0,-1%

echo =^> Configurando workflow-sdd...
echo    Repositorio: %REPO%

:: Verificar se PowerShell esta disponivel
where powershell >nul 2>&1
if errorlevel 1 (
    echo [ERRO] PowerShell nao encontrado.
    pause
    exit /b 1
)

:: Executar o setup via PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%\setup.ps1" -WorkflowRepo "%REPO%"

pause
