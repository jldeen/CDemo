param(
    $Username,
    $Password,
    $FilePath,
    $ServerName,
    $Action
)

$webclient = New-Object System.Net.WebClient

$webclient.Credentials = New-Object System.Net.NetworkCredential($UserName, $Password)

$file = Get-Item -Path $FilePath

$uri = New-Object System.Uri("ftp://$ServerName/$($file.Name)")

if ($Action -eq "Download") {

$webclient.DownloadFile($uri, $FilePath)

} elseif ($Action -eq "Upload") {

$webclient.UploadFile($uri, $FilePath)
}
