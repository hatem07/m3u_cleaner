@echo off
setlocal enabledelayedexpansion

:: Input and output files
set "input_file=input.m3u"
set "output_file=output.m3u"

:: Temporary file to hold valid entries
set "temp_file=temp.m3u"

:: Timeout duration (in seconds)
set "timeout_seconds=7"

:: Clean up old temp files
if exist "%temp_file%" del "%temp_file%"
if exist "%output_file%" del "%output_file%"

:: Count total URLs for progress tracking
set "total_urls=0"
for /f "tokens=*" %%A in ('findstr /c:"http" "%input_file%"') do (
    set /a total_urls+=1
)

:: Initialize counters
set "current_count=0"

:: Read the M3U file line by line
for /f "tokens=*" %%A in ('type "%input_file%"') do (
    set "line=%%A"
    if "!line!"=="!line:#EXTINF=!" (
        :: Process URL line
        set /a current_count+=1
        title Checking !current_count!/!total_urls!

        echo Checking URL: !line!
	wget --spider --timeout=%timeout_seconds% --tries=2 --quiet "!line!"
        if !errorlevel! equ 0 (
            :: URL is valid; append metadata and URL to temp file
            >>"%temp_file%" echo !prev_line!
            >>"%temp_file%" echo !line!
        ) else (
            echo Invalid or timed-out URL: !line!
        )
    ) else (
        :: Save the metadata line
        set "prev_line=!line!"
    )
)

:: Move temp file to final output
move "%temp_file%" "%output_file%"
echo Cleaned M3U file saved as "%output_file%"
pause
