enum ColorEnum {
    red
    green
    blue
    yellow
}

class Participant {
    [String] $name
    [int] $age
    [string] $Color
    [int] $id

    participant([string]$name, [int]$age,
    [ColorEnum]$Color, [int]$id) {
        $this.name = $name
        $this.age = $age
        $this.Color = $Color
        $this.id = $id

    }
    
    [string] ToString () {
        Return '{0},{1},{2},{3}' -f $this.Name, $this.Age, $this.Color, $this.Id
    }
}
function GetUserData {
    $MyUsers = . "$PSScriptRoot\getuser.ps1"

    foreach ($user in $MyUsers) {
        [PSCustomObject]@{
            Name = [string]$user.Name
            Age  = [int]$user.Age
        }
    }
}

Function Get-CourseUser {
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $False)]
        [string]$name,
        [parameter(Mandatory = $False)]
        [int]$OlderThan = 65
    )
    $users = GetUserData
        if ($PSBoundParameters.ContainsKey('Name')) {
        $users = $users | Where-Object {
            $_.Name -eq $Name
        }
    }

    $users | Where-Object {
        $_.Age -gt $OlderThan
    }
}

function Add-CourseUser {
    [CmdletBinding()]
    param (
        [string]$DatabaseFile = "C:\Temp\powershelltraining\PowershellTraining\MyLabFile.csv",

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$Age,

        [Parameter(Mandatory)]
        [ColorEnum]$Color,

        $id = (Get-Random -Minimum 10 -Maximum 100000)
    )

    if (-not $id) {
        $id = [guid]::NewGuid().ToString()
    }

    
 $MyNewUser = [Participant]::new($Name, $Age, $Color, $UserId)
    $MyCsvUser = $MyNewUser.ToString() 
    
    $NewCSv = Get-Content $DatabaseFile -Raw
    $NewCSv += $MyCsvUser

    Set-Content -Value $NewCSv -Path $DatabaseFile
}




function Remove-CourseUser {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$DatabaseFile = "$PSScriptRoot\MyLabFile.csv"
    )

    # Hämta alla användare via helper
    $users = . "$PSScriptRoot\GetUser.ps1"

    # Hitta användaren som ska tas bort
    $RemoveUser = $users | Where-Object {
        $_.Name -eq $Name
    }

    if (-not $RemoveUser) {
        Write-Warning "User '$Name' not found"
        return
    }

    if ($PSCmdlet.ShouldProcess($RemoveUser.Name, 'Remove user')) {

        # Behåll alla UTOM den som ska bort
        $updatedUsers = $users | Where-Object {
            $_.Name -ne $RemoveUser.Name
        }

        # Skriv tillbaka till CSV
        $updatedUsers | Export-Csv -Path $DatabaseFile -NoTypeInformation
    }
    else {
        Write-Output "Did not remove user $($RemoveUser.Name)"
    }
}
