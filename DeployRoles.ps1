# Function to check if the required role is installed on the server
function Check-ServerRole {
    param (
        [string]$serverName,
        [string]$requiredRole
    )

    $roles = Get-WindowsFeature -ComputerName $serverName
    $roleInstalled = $roles | Where-Object { $_.Name -eq $requiredRole -and $_.Installed -eq $true }

    if ($roleInstalled) {
        Write-Host "$requiredRole is installed on $serverName" -ForegroundColor Green
        return $true
    } else {
        Write-Host "$requiredRole is NOT installed on $serverName" -ForegroundColor Red
        return $false
    }
}

# Function to collect server names and session host info
function Collect-ServerInfo {
    Clear-Host
    
    $dom = read-host "Enter the domain FQDN (e.g.Contoso.com)"

    # Ask for Broker Server name
    $brokerServerx = Read-Host "Enter the Broker Server name (e.g. RDCB.$dom)"

    if($brokerServerx -notcontains "*.*"){
        $brokerServer = '{0}.{1}' -f $brokerServerx,$dom
    }else{
        $brokerServer = $brokerServerx
    }

    

    # Ask if the Broker Server is also the Web Access Server
    $isWebAccessServer = Read-Host "Is the Broker Server also the Web Access Server? (y/n)"
    if ($isWebAccessServer -eq 'y') {
        $webAccessServer = $brokerServer
    } else {
        $webAccessServerx = Read-Host "Enter the Web Access Server name (e.g. RDWA.Contoso.com)"
        if($webAccessServerx -notcontains "*.*"){
        $webAccessServer = '{0}.{1}' -f $webAccessServerx,$dom
    }else{
        $webAccessServer = $webAccessServerx
    }
        
    }

    # Ask for Session Host base name
    $sessionHostBaseName = Read-Host "Enter the Session Host base name (e.g. RDSH)"

    # Ask for the number of Session Hosts
    $sessionHostCount = Read-Host "Enter the number of Session Hosts to create"

    # Initialize array for session host names
    $sessionHosts = @()

    # Loop to create session host names with two-digit formatting for numbers < 10
    for ($i = 1; $i -le $sessionHostCount; $i++) {
        $sessionNumber = "{0:D2}" -f $i  # Format number with two digits
        $sessionHosts += "$sessionHostBaseName$sessionNumber.$dom"
    }

    # Output the server names
    $serverList = @{
        "Broker Server"      = $brokerServer
        "Web Access Server"  = $webAccessServer
        "Session Hosts"      = $sessionHosts
    }

    return $serverList
}

# Function to check roles on all servers
function Check-Roles {
    param (
        [string]$brokerServer,
        [string]$webAccessServer,
        [array]$sessionHosts
    )
    
    $allRolesInstalled = $true

    # Check Broker Server for RD Connection Broker role
    $brokerRoleInstalled = Check-ServerRole -serverName $brokerServer -requiredRole "RDS-Connection-Broker"
    if (-not $brokerRoleInstalled) { $allRolesInstalled = $false }

    # Check Web Access Server for RD Web Access role
    $webRoleInstalled = Check-ServerRole -serverName $webAccessServer -requiredRole "RDS-Web-Access"
    if (-not $webRoleInstalled) { $allRolesInstalled = $false }

    # Check each Session Host for RD Session Host role
    foreach ($sessionHost in $sessionHosts) {
        $sessionRoleInstalled = Check-ServerRole -serverName $sessionHost -requiredRole "RDS-RD-Server"
        if (-not $sessionRoleInstalled) { $allRolesInstalled = $false }
    }

    return $allRolesInstalled
}

# Run the function and store the result in a variable
$serverInfo = Collect-ServerInfo

# Display the collected information
Clear-Host
Write-Host "Server Information:" -ForegroundColor Cyan
Write-Host "========================================="
Write-Host "Broker Server: $($serverInfo['Broker Server'])"
Write-Host "Web Access Server: $($serverInfo['Web Access Server'])"
Write-Host "Session Hosts:"
$serverInfo['Session Hosts'] | ForEach-Object { Write-Host "  - $_" }
Write-Host "========================================="

# Check if the required roles are installed
$rolesInstalled = Check-Roles -brokerServer $serverInfo['Broker Server'] -webAccessServer $serverInfo['Web Access Server'] -sessionHosts $serverInfo['Session Hosts']

# If all roles are installed, generate the New-RDSessionDeployment command
if ($rolesInstalled) {
    $sessionHostList = $serverInfo['Session Hosts'] -join '","'
    $deploymentCommand = "New-RDSessionDeployment -ConnectionBroker `"$($serverInfo['Broker Server'])`" -WebAccessServer `"$($serverInfo['Web Access Server'])`" -SessionHost @(`"$sessionHostList`")"

    Write-Host "Deployment Command:" -ForegroundColor Green
    Write-Host $deploymentCommand
} else {
    Write-Host "Not all required roles are installed. Please ensure the roles are properly set up before deploying." -ForegroundColor Red
}
