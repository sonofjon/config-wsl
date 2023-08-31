@rem Run as Administrator
@rem
@rem Reference: https://github.com/microsoft/WSL/issues/8696

@echo Listing all wsl tasks:
@tasklist /M wsl*

@echo Sending kill to wslservice:
@taskkill /IM wslservice.exe /F

@echo Done!
