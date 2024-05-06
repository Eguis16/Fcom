#Codigo creado por Eguis Suarez especialista TI Fcom Spa
#Este codigo esta basado en el Script creado por Jorge Santos Jefe de Soporte TI Fcom Spa
<#Funciones del software: 
- Eliminacion de aplicativos preinstalados de Windows
- Asignacion de nombre de imagen y sistema
- Ejecucion de Sysprep de forma desantendida#>


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

#Creacion de cuenta de local administrador
function CuentadeUsuario {
    #Declaracion de Variables
    $Cuenta = Read-Host "Cuenta"
    $Password = Read-Host -AsSecureString "Contrasena"
    
    # Parameter help description
    try {
        #Creacion de cuenta
        New-LocalUser -Name $Cuenta -Password $Password -AccountNeverExpires -PasswordNeverExpires
        Write-Host "La cuenta $Cuenta se ha creado exitosamente"
        Pause 
        
        #Agregar al usuario a miembro administradores
        Add-LocalGroupMember -Group "Administradores" -Member $Cuenta
        Write-Host "La cuenta '$Cuenta' se ha agregado exitosamente al grupo administradores"
        Pause
    }
    catch {
        Write-Host "Se ha presentado un problema con la cuenta '$Cuenta'"
    }
}

#Generacion de Nombre de Imagen
function ComputerModel {
    #Declaracion de variables
    $Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
    $ModelHP = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $Sku = (Get-CimInstance -ClassName Win32_ComputerSystem).SystemSKUNumber
    $ModelLenovo = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).Version
    $Mtm = (Get-CimInstance -ClassName Win32_ComputerSystem).Model
    $OSVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "DisplayVersion").DisplayVersion
    $OSName = (Get-CimInstance -ClassName Win32_OperatingSystem).Name -split '\|' | Select-Object -First 1
    if ($OSName -eq "Microsoft Windows 10 Pro") {$OSName= "W10PRO"}
    elseif ($OSName -eq "Microsoft Windows 11 Pro") {$OSName = "W11PRO"}
    elseif ($OSName -eq "Microsoft Windows 11 Pro Education") {$OSName = "W11PROEDU"}
    #Llamado
    $Cliente = Read-Host "Cliente"
    $Modelo = Read-Host "Modelo"

    #Asignacion
    if ($Manufacturer -eq "HP" -or $Manufacturer -eq "Hewlett-Packard") {
        $Model = "$ModelHP | $Cliente" + "_$OSName$OSVersion" + "_$Modelo" + "_$Sku"
        $SystemName = (Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model" -Value $Model -Type String -Force | Out-Null)
        
    } 
    elseif ($Manufacturer -eq "LENOVO") {
        $Model = "$ModelLenovo | $Cliente" + "_$OSName$OSVersion" + "_$Modelo" + "$Mtm"
        $SystemName = (Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" -Name "Model" -Value $Model -Type String -Force | Out-Null)
    } else {
        Write-Host "Se ha producido un error en el proceso de asignacion de nombre de imagen"
    }
    Write-Host = "Nombre Asignado -->" + $SystemName
    Pause
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
    Write-Host "2. Asignacion de nombre de Imagen"
    Write-Host "3. Creacion de cuenta local del Cliente"
    Write-Host "4. Preparacion de imagen (Sysprep)"
    Write-Host "5. Exit"
    $seleccion = Read-Host "Elija una opcion: "

    switch ($seleccion) {
        '1' {Bloatware; Show-Menu}
        '2' {ComputerModel; Show-Menu}
        '3' {CuentadeUsuario; Show-Menu}
        '4' {Invoke_Sysprep; Show-Menu}
        '5' {Exit}
        default {Write-Host "Opcion invalida. Porfavor intente de nuevo."; Show-Menu}
    }

}

Show-Menu