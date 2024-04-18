# Codigo creado por Eguis Suarez especialista TI Fcom Spa
#Autoelevacion de Script main.ps1
function AdminPrivileges {
    # Verificar si el usuario tiene privilegios de administrador
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Este script requiere privilegios de administrador."
        exit
    }
}

#Eliminacion de paquetes de aplicaciones presintaladas de microsoft
function Bloatware {
    
    $AppList = @(

        "Microsoft.BingNews"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.RemoteDesktop"
        "Microsoft.SkypeApp"
        "Microsoft.StorePurchaseApp"
        "Microsoft.Office.Todo.List"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
    )
    
    foreach ($Bloat in $AppList) {
        Get-Package -Name $Bloat | Remove-AppPackage
        Get-AppProvisionedPackage -Online | Where-Object DisplayName -Like
        Write-Host "Eliminando paquete $Bloat"
    }
}
#Preparacion de imagen con sysprep
function Invoke_Sysprep {

    # Ruta de archivo unattend.xml
    $UnattendFile = Join-Path -Path $PSScriptRoot -ChildPath ".\unattend.xml"
    # Ejecucion de Sysprep
    Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" -ArgumentList "/generalize /oobe /shutdown /unattend:$UnattendFile" -Wait
    Write-Host
}

function Show-Menu {
    Clear-Host
    Write-Host "1. Eliminacion de aplicativos Bloatware de Micorsoft"
    Write-Host "2. Preparacion de imagen (Sysprep)"
    Write-Host "3. Exit"
    $seleccion = Read-Host "Elija una opcion"

    switch ($seleccion) {
        '1' {Bloatware; Show-Menu}
        '2' {Invoke_Sysprep; Show-Menu}
        '3' {Exit}
        default {Write-Host "Opcion invalida. Porfavor intente de nuevo."; Show-Menu}
    }
    
}

Show-Menu