@echo off
REM Gradle launcher script for Windows
set DIR=%~dp0
java -jar "%DIR%gradle\wrapper\gradle-wrapper.jar" %*
