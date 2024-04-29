# Codigo creado por Eguis Suarez especialista TI Fcom Spa
#Autoelevacion de Script main.ps1
function AdminPrivileges {
    # Verificar si el usuario tiene privilegios de administrador
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Este script requiere privilegios de administrador."
        exit
    }
}

#Eliminacion de Bloatware de Microsoft.
function Bloatware () {
    #Ruta de archivo applist.txt
    $applistFile = Join-Path -Path $PSScriptRoot -ChildPath ".\applist.txt"

    if(Test-Path $applistFile) {
        Get-Content $applistFile | ForEach-Object {
            $line = $_.Trim() #Limpieza de espacios en blanco al princpio y al final
            if (-NOT $line.StartsWith("#") -and -NOT [string]::IsNullOrWhiteSpace($line)) {
                $word = $line.Trim() #Limpieza de espacios en blanco al principio y al final.
                Clear-Host
                Write-Host "Desinstalando --> $word"
                Get-AppxPackage -AllUsers -Name "*$word*" | Remove-AppxPackage
                Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "**$word"} |
                ForEach-Object {Remove-ProvisionedAppPackage -Online -AllUsers -PackageName $_.PackageName}
            }
        }
    } else {
         Write-Host "El archivo applist.txt no se encuentra en la ruta $applistFile"
    }
}

#Generacion de Nombre de Imagen
function NombreMaquina {
    #declaracion de variables
    $Manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
    $ModelHP = (Get-WmiObject -Class Win32_ComputerSystem).Model
    $Sku = (Get-WmiObject -Class Win32_ComputerSystem).SystemSKUNumber
    $LenovoModel = (Get-WmiObject -Class Win32_ComputerSystemProduct).Version
    $MtM = (Get-WmiObject -Class Win32_ComputerSystem).Model

    #Obtecion de nombre del Sistema Operativo
    $osname = (Get-WmiObject -Class Win32_OperatingSystem).Name
    $osname = $osname -split '\|' | Select-Object -First 1
    if($osname -eq "Microsoft Windows 10 Pro") { $osname = "W10PRO"}
    elseif ($osname -eq "Microsoft Windows 11 Pro") { $osname = "W11PRO"}
    elseif ($osname -eq "Microsoft Windows 11 Pro Education") {$osname = "W11PROEDU"}
    #Obtencion de version del SO
    $Version = (Get-ItemProperty -Path "HKLM:\\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "DisplayVersion").DisplayVersion

    #Solicitud de informacion al usuario
    Clear-Host
    Write-Host "Indique la porcion del nombre de la imagen que corresponde al Cliente"
    Write-Host "Ejemplo: >CLIENTE<_W11PRO23H2_MODELO_PN"
    $Client = Read-Host "Cliente"
    Clear-Host
    Write-Host "Indique la porcion del nombre de la imagen que corresponde al Modelo"
    Write-Host "Ejemplo: >CLIENTE<_W11PRO23H2_MODELO_PN"
    Write-Host "Ejemplo Modelo HP: EliteBook 640 G10 >640G10"
    Write-Host "Ejemplo Modelo Lenovo: Lenovo T14 Gen 3 > T14GEN3"
    $modelo = Read-Host "Modelo"
    
    #Actualizacion de registro
    if ($Manufacturer -eq "HP" -or $Manufacturer -eq "Hewllet-Packard") {
        $model = "$modelhp | $client" + "_$osname$version_$modelo_$sku"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model" -Value $model -PropertyType "String" -Force | Out-Null
    }
    elseif ($Manufacturer -eq "LENOVO") {
        $model = "$modellenovo | $cliente" + "_$osname$version_$modelo_sku"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model" -Value $model -PropertyType "String" -Force | Out-Null       
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
    Write-Host "1. Eliminacion de aplicativos Bloatware de Microsoft"
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