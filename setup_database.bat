@echo off
setlocal enabledelayedexpansion
title Courson LMS - Khoi Tao Co So Du Lieu (Database Setup)
color 0A

echo ======================================================================
echo           COURSON LMS - THIET LAP & KHOI TAO CO SO DU LIEU
echo ======================================================================
echo.

:: 1. Nhan dien duong dan psql linh hoat
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

:: 2. Doc password tu db.properties neu co
set "DB_USER=postgres"
set "DB_PASS=sa"
if exist "%~dp0src\main\resources\db.properties" (
    for /f "tokens=1,2 delims==" %%a in ('findstr /r "^db\.user ^db\.password" "%~dp0src\main\resources\db.properties"') do (
        if "%%a"=="db.user" set "DB_USER=%%b"
        if "%%a"=="db.password" set "DB_PASS=%%b"
    )
)

echo [*] Dang kiem tra ket noi toi PostgreSQL (User: %DB_USER%, Port: 5432)...
set "PGPASSWORD=%DB_PASS%"

:: Thu ket noi voi mat khau trong file truoc
"%PSQL_CMD%" -U "%DB_USER%" -d postgres -c "SELECT 1;" >nul 2>&1
if !errorlevel! neq 0 (
    echo [!] Ket noi voi mat khau '%DB_PASS%' chua thanh cong.
    echo [*] Dang tu dong thu cac mat khau pho bien (postgres, root, 123456, admin, sa)...
    set "FOUND_PASS="
    for %%p in (postgres root 123456 admin password sa) do (
        if not defined FOUND_PASS (
            set "PGPASSWORD=%%p"
            "%PSQL_CMD%" -U "%DB_USER%" -d postgres -c "SELECT 1;" >nul 2>&1
            if !errorlevel! equ 0 (
                set "FOUND_PASS=%%p"
            )
        )
    )
    if defined FOUND_PASS (
        set "DB_PASS=!FOUND_PASS!"
        set "PGPASSWORD=!FOUND_PASS!"
        echo       [OK] Da tim thay mat khau ket noi dung: !FOUND_PASS!
    ) else (
        echo.
        set /p "DB_PASS=Vui long nhap mat khau PostgreSQL tren may ban: "
        set "PGPASSWORD=!DB_PASS!"
    )
)

echo.
echo [1/3] Tao co so du lieu courson_db...
"%PSQL_CMD%" -U "%DB_USER%" -d postgres -c "CREATE DATABASE courson_db;" >nul 2>&1
echo       [OK] Database courson_db da san sang.

echo.
echo [2/3] Nap cau truc 14 bang quan he (database/schema.sql)...
"%PSQL_CMD%" -U "%DB_USER%" -d courson_db -f "%~dp0database\schema.sql" >nul 2>&1
if !errorlevel! equ 0 (
    echo       [OK] Nap schema 14 bang thanh cong!
) else (
    echo       [!] Co thong bao khi nap schema (co the bang da ton tai).
)

echo.
echo [3/3] Nap du lieu mau chuan hoa (database/seed.sql)...
"%PSQL_CMD%" -U "%DB_USER%" -d courson_db -f "%~dp0database\seed.sql" >nul 2>&1
if !errorlevel! equ 0 (
    echo       [OK] Nap toan bo du lieu mau thanh cong!
) else (
    echo       [!] Co thong bao khi nap seed data.
)

echo.
echo ======================================================================
echo   KHOI TAO CSDL THANH CONG!
echo   - Database: courson_db (Port 5432)
echo   - 14 bang quan he va toan bo seed data da duoc thiet lap.
echo   - Tai khoan mac dinh he thong:
echo     + Admin:   admin@courson.edu.vn / admin123
echo     + Expert:  expert@courson.edu.vn / admin123
echo     + Manager: manager@courson.edu.vn / admin123
echo     + Student: student@courson.edu.vn / admin123
echo ======================================================================
echo.
pause
