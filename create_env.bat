@echo off
setlocal enabledelayedexpansion

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find "IPv4"') do (
    set "COMPUTER_IP=%%a"
    rem Trim leading and trailing spaces
    set "COMPUTER_IP=!COMPUTER_IP: =!"
    :: Write to .env file
	echo COMPUTER_IP=!COMPUTER_IP! > .env
    goto :next
)
:next

echo .env file created with COMPUTER_IP=!COMPUTER_IP!
