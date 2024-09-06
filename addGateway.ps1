$dom = read-host "Enter the domain FQDN (e.g.Contoso.com)"

    # Ask for Gateway Server name
    $GatewayServer = Read-Host "Enter the Gateway Server name (e.g. RDCB.$dom)"

    $gatewayServer = '{0}.{1}' -f $gatewayServerx,$dom

    $externalFQDN = read-host "Enter the external FQDN (RDWEB.externalurl.com)"

Add-RDServer -Server $GatewayServer -Role "RDS-GATEWAY" -ConnectionBroker $GatewayServer -GatewayExternalFqdn $externalFQDN