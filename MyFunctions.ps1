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
        [string]$DatabaseFile = "$PSScriptRoot\MyLabFile.csv",

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$Age,

        [Parameter(Mandatory)]
        [ValidateSet('red','green','blue','yellow')]
        [string]$Color,

        [string]$UserID
    )

    if (-not $UserID) {
        $UserID = [guid]::NewGuid().ToString()
    }

    
    $newUser = [PSCustomObject]@{
        Id    = $UserID
        Name  = $Name
        Age   = $Age
        Color = $Color
    }

    if (-not (Test-Path $DatabaseFile)) {
        $newUser | Export-Csv -Path $DatabaseFile -NoTypeInformation
    }
    else {
        $newUser | Export-Csv -Path $DatabaseFile -Append -NoTypeInformation
    }

    return $newUser
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
