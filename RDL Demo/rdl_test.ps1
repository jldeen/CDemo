#region - Connection Data
$reportServerUri = "http://localhost/reportserver/ReportService2010.asmx?wsdl"
$rs = New-WebServiceProxy -Uri $reportServerUri -UseDefaultCredential

                          -Namespace "SSRS"
#endregion - Connection Data

#region - Upload .rdl
# Upload all .rdl files in the current directory to a specific folder, and 
# set their datasource references to the same shared datasource (should 
# already be deployed).
$targetFolderPath = "/Reports/MyNewReports"
$targetDatasourceRef = "/Data Sources/mySharedDataSource"
$warnings = $null

Get-ChildItem *.rdl | Foreach-Object {
    $reportName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)

    Write-Output "Uploading report ""$reportName"" to ""$targetFolderPath""..."
    $report = $rs.CreateCatalogItem(
        "Report",         # Catalog item type
        $reportName,      # Report name
        $targetFolderPath,# Destination folder
        $true,            # Overwrite report if it exists?
        $bytes,           # .rdl file contents
        $null,            # Properties to set.
        [ref]$warnings)   # Warnings that occured while uploading.

    $warnings | ForEach-Object {
        Write-Output ("Warning: {0}" -f $_.Message)
    }

    # Get the (first) *design-time* name of the data sources that the 
    # uploaded report references. Note that this might be different from 
    # the name of the datasource as it is deployed on the report server!
    $referencedDataSourceName = (@($rs.GetItemReferences($report.Path, "DataSource")))[0].Name

    # Change the datasource for the report to $targetDatasourceRef
    # Note that we can access the types such as DataSource with the prefix 
    # "SSRS" only because we specified that as our namespace when we 
    # created the proxy with New-WebServiceProxy.
    $dataSource = New-Object SSRS.DataSource
    $dataSource.Name = $referencedDataSourceName      # Name as used when designing the Report
    $dataSource.Item = New-Object SSRS.DataSourceReference
    $dataSource.Item.Reference = $targetDatasourceRef # Path to the shared data source as it is deployed here.
    $rs.SetItemDataSources($report.Path, [SSRS.DataSource[]]$dataSource)
}
#endregion - Upload .rdl