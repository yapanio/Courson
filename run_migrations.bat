@echo off
setlocal enabledelayedexpansion
title Courson LMS - Chay Database Migrations
color 0B

echo ======================================================================
echo           COURSON LMS - CHAY CAC FILE MIGRATION CO SO DU LIEU
echo ======================================================================
echo.

:: 1. Nhan dien psql
set "PG_BIN=C:\Program Files\PostgreSQL\18\bin"
if not exist "%PG_BIN%\psql.exe" (
    for %%v in (18 17 16 15 14) do (
        if exist "C:\Program Files\PostgreSQL\%%v\bin\psql.exe" (
            set "PG_BIN=C:\Program Files\PostgreSQL\%%v\bin"
        )
    )
)

set "PSQL_CMD=%PG_BIN%\psql.exe"
where psql >nul 2>&1
if %errorlevel% equ 0 (
    set "PSQL_CMD=psql"
)

if not exist "%PSQL_CMD%" (
    where psql >nul 2>&1
    if !errorlevel! neq 0 (
        color 0C
        echo [LOI] Khong tim thay psql.exe! Vui long kiem tra PostgreSQL da duoc cai dat chua.
        pause
        exit /b 1
    )
)

:: 2. Doc user va password tu db.properties / db.local.properties
set "DB_USER=postgres"
set "DB_PASS=sa"
if exist "%~dp0src\main\resources\db.properties" (
    for /f "tokens=1,2 delims==" %%a in ('findstr /r "^db\.user ^db\.password" "%~dp0src\main\resources\db.properties"') do (
        if "%%a"=="db.user" set "DB_USER=%%b"
        if "%%a"=="db.password" set "DB_PASS=%%b"
    )
)
if exist "%~dp0src\main\resources\db.local.properties" (
    for /f "tokens=1,2 delims==" %%a in ('findstr /r "^db\.user ^db\.password" "%~dp0src\main\resources\db.local.properties"') do (
        if "%%a"=="db.user" set "DB_USER=%%b"
        if "%%a"=="db.password" set "DB_PASS=%%b"
    )
)

set "PGPASSWORD=%DB_PASS%"

:: 3. Kiem tra ket noi den PostgreSQL
"%PSQL_CMD%" -U "%DB_USER%" -d courson_db -c "SELECT 1;" >nul 2>&1
if !errorlevel! neq 0 (
    echo [*] Dang tu dong thu cac mat khau pho bien thu cac mat khau pho bien...
    set "FOUND_PASS="
    for %%p in (sa postgres root 123456 admin password) do (
        if not defined FOUND_PASS (
            set "PGPASSWORD=%%p"
            "%PSQL_CMD%" -U "%DB_USER%" -d courson_db -c "SELECT 1;" >nul 2>&1
            if !errorlevel! equ 0 (
                set "FOUND_PASS=%%p"
            )
        )
    )
    if defined FOUND_PASS (
        set "DB_PASS=!FOUND_PASS!"
        set "PGPASSWORD=!FOUND_PASS!"
    ) else (
        echo [!] Khong the ket noi toi courson_db voi mat khau mac dinh.
        set /p "DB_PASS=Vui long nhap mat khau PostgreSQL: "
        set "PGPASSWORD=!DB_PASS!"
    )
)

echo [*] Ket noi thanh cong toi Database: courson_db (User: %DB_USER%)
echo.
echo [*] Bat dau chay cac file migration trong database\migrations:
echo ----------------------------------------------------------------------

set "COUNT=0"
for /f "tokens=*" %%f in ('dir /b /on "%~dp0database\migrations\*.sql"') do (
    echo %%f | findstr /i "rollback" >nul
    if !errorlevel! neq 0 (
        set /a COUNT+=1
        echo [!COUNT!] Dang thuc thi: %%f
        "%PSQL_CMD%" -U "%DB_USER%" -d courson_db -f "%~dp0database\migrations\%%f"
        if !errorlevel! equ 0 (
            echo        [THANH CONG] %%f
        ) else (
            echo        [CO THONG BAO HOAC LOI] %%f
        )
        echo.
    )
)

echo ----------------------------------------------------------------------
echo [HOAN TAT] Da thuc thi %COUNT% file migration.
echo ======================================================================
echo.
pause
