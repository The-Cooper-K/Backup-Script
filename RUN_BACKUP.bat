@echo off

::Step 1 ZIP THE FOLDER
echo --------------
echo PREPARING ZIP
echo --------------
ssh -i "C:\Users\user\Desktop\Rent Connect Solutions inc\Rent ConnectME Documents\ssh keys\Alt private key.pem" rcs@99.236.76.230 -t "cd /var/www/; echo  | sudo -S zip -r RCM-BACKUP- rentconnectme.com; exit; bash"
 
::Step 2 GET THE FOLDER
echo ------------------------
echo BACKUP TRANSFER STARTED
echo ------------------------
"C:\Program Files (x86)\WinSCP\WinSCP.com" /log="C:\Users\user\Desktop\Rent Connect Solutions inc\Scripts\Backups\LOGFILE.log" /ini=nul /script="C:\Users\user\Desktop\Rent Connect Solutions inc\Scripts\Backups\BackupScript.txt"

::Step 3 TIMESTAMP THE FOLDER
echo ---------------
echo UPDATING FOLDER
echo ---------------

@echo off
set mydate=%date:/=%
set TIMESTAMP=%mydate: =_%
echo Timestamp recorded as: %TIMESTAMP%
cd C:\Users\user\Desktop\
ren "RCM-BACKUP-.zip" "RCM-BACKUP-%TIMESTAMP%.zip"

::Step 4 OFFSITE BACKUP
echo -------------------------
echo SENDING TO OFFSITE BACKUP
echo -------------------------

move "C:\Users\user\Desktop\RCM-BACKUP-%TIMESTAMP%.zip" "\\copenas.synology.me\Lucas-Backups\Web Server Back Up

:: CLEANUP STEP FOR WHEN EVERYTHING IS WORKING PROPERLY
rmdir /q "C:\Users\user\Desktop\RCM-BACKUP-%TIMESTAMP%.zip"

::Step 5 SEND EMAIL CONFIRMATION
echo --------------------------
echo SENDING EMAIL CONFIRMATION
echo --------------------------

@echo off

::set winscp log file location
set WINSCP_LOG="C:\Users\user\Desktop\Rent Connect Solutions inc\Scripts\Backups\LOGFILE.log"

rem Check WinSCP result and prepare the email message
if %ERRORLEVEL% equ 0 (
    set WINSCP_MESSAGE=RCM Wordpress backup uploaded successfully.
    set WINSCP_CODE=0
) else (
    set WINSCP_MESSAGE=RCM Wordpress backup failed, see attached log.
    set WINSCP_CODE=1
)

::log the status of backup run
echo %WINSCP_MESSAGE%
 
rem Send the email message

::setup email recipients and message
set SMTP_FROM="support@rentconnectme.com"
set SMTP_TO="lucas@rentconnectme.com"
set SMTP_SERVER="smtp.gmail.com"
set SMTP_USERNAME="lucas@rentconnectme.com"
set SMTP_PASSWORD="mpju rhwx nngo oesx"
set SMTP_ATTACHMENT="C:\Users\user\Desktop\Rent Connect Solutions inc\Scripts\Backups\LOGFILE.log"

powershell -ExecutionPolicy Bypass -Command Send-MailMessage ^
    -From %SMTP_FROM% -To %SMTP_TO% -Subject '%WINSCP_MESSAGE%' -Body '%WINSCP_MESSAGE%' -Attachment '%SMTP_ATTACHMENT%' ^
    -SmtpServer %SMTP_SERVER% -UseSsl -Credential (New-Object System.Management.Automation.PSCredential ^
    ('%SMTP_USERNAME%', (ConvertTo-SecureString '%SMTP_PASSWORD%' -AsPlainText -Force)))

exit /b %WINSCP_CODE%

echo -----------------
echo PROCESS COMPELTED
echo -----------------

exit