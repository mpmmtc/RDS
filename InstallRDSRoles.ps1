# Function to display the main menu
$exit = $false
function Show-MainMenu {
    Clear-Host
    Write-Host "Server Role Configuration" -ForegroundColor Cyan
    Write-Host "======================================"
    Write-Host "1. Make this a Broker Server?"
    Write-Host "2. Make this a Session Host?"
    Write-Host "3. Exit"
    Write-Host "======================================"
}

# Function to check if it's a broker server
function Is-BrokerServer {
    Clear-Host
    Write-Host "Also make this a Web Access Server? (y/n)" -ForegroundColor Yellow
    $response = Read-Host "Enter your choice"

    if ($response -eq 'y') {
        Install-WindowsFeature RDS-Connection-Broker -IncludeManagementTools
        Install-WindowsFeature RDS-web-access -IncludeManagementTools
    } elseif ($response -eq 'n') {
        Install-WindowsFeature RDS-Connection-Broker -IncludeManagementTools
    } else {
        Write-Host "Invalid input, please try again."
        Start-Sleep -Seconds 2
        break
    }
}



# Function to check if it's a session host
function Is-SessionHost {
    Install-WindowsFeature RDS-RD-server -IncludeManagementTools
}

# Main execution loop
while(-not $exit) {
    Show-MainMenu
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        1 {
            Is-BrokerServer
            Start-Sleep -Seconds 2
        }
        2 {
            Is-SessionHost
            Start-Sleep -Seconds 2
        }
        3 {
            Write-Host "Exiting..." -ForegroundColor Green
            $exit = $true #break
        }
        default {
            Write-Host "Invalid choice, please select a valid option."
            Start-Sleep -Seconds 2
        }
    }
}
