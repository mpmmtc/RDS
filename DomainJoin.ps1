$compname = Read-Host -Prompt "Enter Computer name"
$dom = Read-Host -Prompt "Enter Domain Name"

try{
    Rename-Computer $compname
    add-computer -domainname $dom
    Restart-Computer 
}catch{
    write-host "error joining domain"
}