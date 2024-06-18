function Disable-InactiveADUsers {
    param(
        [int]$Days = 30  # Default to 30 days if no value is provided
    )

    Import-Module ActiveDirectory

    $date = (Get-Date).AddDays(-$Days)
    $fileTime = $date.ToFileTime()

    $inactiveUsers = Get-ADUser -Filter {LastLogonTimeStamp -lt $fileTime} -Properties LastLogonTimeStamp

    foreach ($user in $inactiveUsers) {
        # Check if the user account is already disabled
        if ($user.Enabled -eq $true) {
            try {
                # Attempt to disable the user account
                Disable-ADAccount -Identity $user
                Write-Output "Disabled user: $($user.SamAccountName)"
            }
            catch {
                Write-Error "Failed to disable user $($user.SamAccountName): $_"
            }
        } else {
            Write-Verbose "User $($user.SamAccountName) is already disabled."
        }
    }

    # Optionally, return the list of disabled users or some status information
    $inactiveUsers | Where-Object { $_.Enabled -eq $false } | Select-Object SamAccountName, @{Name="LastLogon"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
}
