@echo off
setlocal enabledelayedexpansion
title Courson LMS - Quick Start
color 0B

echo ======================================================================
echo                 COURSON LMS - KHOI CHAY LOCAL
echo ======================================================================
echo.

:: 0. Tu dong nhan dien duong dan Java, Tomcat, PostgreSQL linh hoat cho moi may
if not exist "%JAVA_HOME%\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-17"
    for /d %%i in ("C:\Program Files\Java\jdk-17*" "C:\Program Files\Java\jdk-21*" "C:\Program Files\Eclipse Adoptium\jdk-17*" "C:\Program Files\Eclipse Adoptium\jdk-21*") do (
        if exist "%%i\bin\java.exe" set "JAVA_HOME=%%i"
    )
)

if not exist "%CATALINA_HOME%\bin\catalina.bat" (
    set "CATALINA_HOME=C:\Program Files\Apache Software Foundation\Tomcat 10.1"
    for /d %%i in ("C:\Program Files\Apache Software Foundation\Tomcat 10*" "C:\apache-tomcat-10*" "D:\apache-tomcat-10*") do (
        if exist "%%i\bin\catalina.bat" set "CATALINA_HOME=%%i"
    )
)

if not exist "%PG_BIN%\pg_isready.exe" (
    set "PG_BIN=C:\Program Files\PostgreSQL\18\bin"
    set "PG_DATA=C:\Program Files\PostgreSQL\18\data"
    for %%v in (18 17 16 15 14) do (
        if exist "C:\Program Files\PostgreSQL\%%v\bin\pg_isready.exe" (
            set "PG_BIN=C:\Program Files\PostgreSQL\%%v\bin"
            set "PG_DATA=C:\Program Files\PostgreSQL\%%v\data"
        )
    )
)

set "APP_URL=http://localhost:8080/Courson/"

:: 1. Kiem tra & Khoi dong PostgreSQL
echo [1/3] Kiem tra PostgreSQL Database (Port 5432)...
"%PG_BIN%\pg_isready.exe" -q >nul 2>&1
if !errorlevel! equ 0 (
    echo       [OK] PostgreSQL da san sang.
) else (
    echo       [*] Dang khoi dong PostgreSQL Service...
    "%PG_BIN%\pg_ctl.exe" start -D "%PG_DATA%" -s >nul 2>&1
    if !errorlevel! neq 0 (
        start "PostgreSQL Service" /min "%PG_BIN%\postgres.exe" -D "%PG_DATA%"
    )
    ping 127.0.0.1 -n 3 >nul
    "%PG_BIN%\pg_isready.exe" -q >nul 2>&1
    if !errorlevel! equ 0 (
        echo       [OK] Khoi dong PostgreSQL thanh cong!
    ) else (
        echo       [!] Dang cho PostgreSQL ket noi...
        ping 127.0.0.1 -n 3 >nul
    )
)
echo.

:: 2. Tu dong dong bo giao dien JSP, Classes va xoa cache
echo [2/3] Dong bo giao dien JSP va class vao Tomcat...

:: Kiem tra va dung Tomcat cu truoc khi xoa cache (tranh loi Jasper ClassNotFound)
netstat -ano | find "8080" | find "LISTENING" >nul 2>&1
if !errorlevel! equ 0 (
    echo       [*] Dang dung Tomcat de dong bo ma nguon moi...
    for /f "tokens=5" %%a in ('netstat -ano ^| find "8080" ^| find "LISTENING"') do (
        taskkill /PID %%a /F >nul 2>&1
    )
    ping 127.0.0.1 -n 2 >nul
)

:: Tim lenh Maven linh hoat
where mvn >nul 2>&1
if !errorlevel! equ 0 (
    set "MVN_CMD=mvn"
) else (
    set "MVN_CMD=C:\Program Files\NetBeans-17\netbeans\java\maven\bin\mvn.cmd"
    for /d %%i in ("C:\Program Files\NetBeans-*\netbeans\java\maven\bin\mvn.cmd" "C:\Program Files\apache-maven*\bin\mvn.cmd") do (
        if exist "%%i" set "MVN_CMD=%%i"
    )
)

if exist "%MVN_CMD%" (
    echo       [*] Kiem tra bien dich nhanh Java...
    call "%MVN_CMD%" compile -DskipTests >nul 2>&1
)
robocopy "%~dp0src\main\webapp" "%CATALINA_HOME%\webapps\Courson" /E /NFL /NDL /NJH /NJS >nul 2>&1
if exist "%~dp0target\classes" (
    robocopy "%~dp0target\classes" "%CATALINA_HOME%\webapps\Courson\WEB-INF\classes" /E /NFL /NDL /NJH /NJS >nul 2>&1
)
if exist "%~dp0target\Courson\WEB-INF\lib" (
    robocopy "%~dp0target\Courson\WEB-INF\lib" "%CATALINA_HOME%\webapps\Courson\WEB-INF\lib" /E /NFL /NDL /NJH /NJS >nul 2>&1
)
if exist "%CATALINA_HOME%\work\Catalina" (
    rmdir /S /Q "%CATALINA_HOME%\work\Catalina" >nul 2>&1
)
echo       [OK] Da dong bo webapp va lam moi cache thanh cong.
echo.

:: 3. Kiem tra & Khoi dong Apache Tomcat 10.1
echo [3/3] Khoi dong Apache Tomcat 10.1 (Port 8080)...
start "Courson LMS - Tomcat Server" "%CATALINA_HOME%\bin\catalina.bat" run
echo       [*] Dang khoi chay webapp...
ping 127.0.0.1 -n 4 >nul
echo.

echo ======================================================================
echo       HE THONG DA SAN SANG!
echo       Dia chi: %APP_URL%
echo ======================================================================
echo.
echo Dang mo trinh duyet toi Courson LMS...
start "" "%APP_URL%"

echo.
echo Cua so nay se tu dong dong sau 3 giay (Server tiep tuc chay ngam).
ping 127.0.0.1 -n 4 >nul
