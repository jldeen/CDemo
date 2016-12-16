Param(
[string]$Source,
[string]$Destination
)


#Specify both source and destination directories  

$Source="C:/"
$Destination="C:/Dir"    
 
#FTP Server
$ftp = "ftp://ftp.server.com/dir/" 
$user = "user" 
$pass = "Pass"  
 
$webclient = New-Object System.Net.WebClient 

#Manual Password Auth 
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)

#Password Auth Prompt
# $webclient.Credentials = (Get-Credential).GetNetworkCredential()  
 
#Additioanl - List every sql server trace file 
foreach($item in (dir $Dir "*.trc")){ 
    "Uploading $item..." 
    $uri = New-Object System.Uri($ftp+$item.Name) 
    $webclient.UploadFile($uri, $item.FullName) 
 } 

