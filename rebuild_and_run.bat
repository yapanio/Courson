@echo off
setlocal enabledelayedexpansion
title Courson LMS - Rebuild & Run
color 0E

echo ======================================================================
echo             COURSON LMS - BIEN DICH VA KHOI CHAY (MAVEN)
echo ======================================================================
echo.

:: 0. Tu dong nhan dien duong dan Java, Tomcat, Maven linh hoat
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

where mvn >nul 2>&1
if !errorlevel! equ 0 (
    set "MVN_CMD=mvn"
) else (
    set "MVN_CMD=C:\Program Files\NetBeans-17\netbeans\java\maven\bin\mvn.cmd"
    for /d %%i in ("C:\Program Files\NetBeans-*\netbeans\java\maven\bin\mvn.cmd" "C:\Program Files\apache-maven*\bin\mvn.cmd") do (
        if exist "%%i" set "MVN_CMD=%%i"
    )
)

echo [*] Dang tat Tomcat cu truoc khi build...
call "%~dp0stop_local.bat" >nul 2>&1

echo [1/3] Dang bien dich va dong goi bang Maven...
call "%MVN_CMD%" clean package -DskipTests
if !errorlevel! neq 0 (
    color 0C
    echo.
    echo [LOI] Qua trinh build Maven that bai! Vui long kiem tra lai code.
    pause
    exit /b !errorlevel!
)
echo       [OK] Dong goi Courson.war thanh cong!
echo.

echo [2/3] Trien khai Courson.war vao Tomcat...
if exist "%CATALINA_HOME%\webapps\Courson" (
    rmdir /S /Q "%CATALINA_HOME%\webapps\Courson" >nul 2>&1
)
if exist "%CATALINA_HOME%\work\Catalina\localhost\Courson" (
    rmdir /S /Q "%CATALINA_HOME%\work\Catalina\localhost\Courson" >nul 2>&1
)
copy /Y "%~dp0target\Courson.war" "%CATALINA_HOME%\webapps\Courson.war" >nul
echo       [OK] Da cap nhat Courson.war vao Tomcat webapps.
echo.

echo [3/3] Khoi chay he thong...
call "%~dp0start_local.bat"
