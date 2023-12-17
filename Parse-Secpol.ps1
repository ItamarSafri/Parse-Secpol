function Parse-Secpol {
    <#
.SYNOPSIS
    Parses the Security Policy (secpol) and exports the results to a CSV file.

.DESCRIPTION
    This script exports the local Security Policy (secpol) settings to a temporary file,
    parses the contents, and outputs the results as a custom object. Additionally, it
    provides an option to export the parsed data to a CSV file.

.PARAMETER Path
    The temporary path for the secpol export. Default value is "C:\temp".

.PARAMETER ExportPath
    The export path for a CSV report. It must be a valid existing folder.
    If not specified, the script only parses the secpol settings without exporting to CSV.

.EXAMPLE
    Parse-Secpol -Path "D:\Temp" -ExportPath "D:\Reports"
    Parses the secpol settings and exports the results to a CSV file located at "D:\Reports".

.NOTES
    File Name      : Parse-Secpol.ps1
    Prerequisite   : PowerShell 5.1 or later
    Author         : Itamar Safri

#>
    [CmdletBinding()]
    [OutputType([psobject])]
    param (
        # The temp path for the secpol export
        [System.IO.FileInfo]$Path = "C:\temp",
        # The export path for a CSV report
        [ValidateScript({
            $item = Get-Item -LiteralPath $_ -ErrorAction Ignore
            if(-Not $item){
                throw "Export path does not exist" 
            }
            elseif(-Not ($item.PSIsContainer) ){
                throw "Export path is not a folder" 
            }
            return $true
        })]
        [Parameter(Mandatory=$False)]
        [AllowNull()]
        [System.IO.FileInfo]$ExportPath = $null
    )
    
    begin {
        # Verify if admin
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
            Write-Host "Please run the script with local admin privileges" -Fore Red
            break
        }
        Write-Verbose "Initialzing Function ..."
        $fullPath = "$Path\secpol.cfg"
        $pathToTest =  Split-Path $fullPath
        if (!(Test-Path $pathToTest)){
            Write-Host "Folder does not exists!"
            $create = Read-Host "Create the folder? (Y/N)"
            if ($create.ToUpper() -eq "Y"){
                Write-Host "Creating the folder $pathToTest"
                try{
                    New-Item -ItemType Directory -Path $pathToTest -Force -ErrorAction Stop | Out-Null
                    Write-Verbose "Created Succesfully"
                }catch{
                    Write-Host "Failed to create the folder $pathToTest"
                    Write-Host "Error: $_"
                    break
                }
            }else{
                Write-Host "Exiting .."
                break
            }
        }
    }process {
        # Export secpol settings to a temporary file
        secedit /export /cfg $fullPath| Out-Null

        # Read the secpol file and parse its contents
        $secpol = (Get-Content $fullPath)
        $parse = ($secpol | Where-Object {$_ -notmatch "\[(.*)\]"}).Replace('\','\\') | ConvertFrom-StringData

        # Create a custom object to store parsed data
        $object = [PSCustomObject] @{}

        # Iterate through parsed data and populate the custom object
        foreach ($line in $parse){
            if($line.Values -like "*s-1-*"){
                    $users = @()
                foreach ($sid in $line.Values.Split(',')){
                    $sidObj = New-Object System.Security.Principal.SecurityIdentifier($SID.Replace('*','').Trim())
                    $user = ($sidObj.Translate([System.Security.Principal.NTAccount])).Value
                    $users += $user
                    $value = $users -join ","
                }
            }else{
                $value = $line.Values -join ","
            }
            $object | Add-Member -MemberType NoteProperty -Name "$([string[]]$line.Keys)" -Value $value -Force
        }

        # Export to CSV if ExportPath is specified
        if ($ExportPath){
            $fullExportPath = "$ExportPath\secpol_$($PID).csv"
            try{
                $object | Export-Csv -Path $fullExportPath -NoTypeInformation -Force -ErrorAction Stop
                Write-Verbose "CSV Exported"
            }catch{
                Write-Host "Failed to export CSV"
                Write-Host "Error: $_"
            }
        }
        $object
                
    }end {
        # Clean up the temporary secpol file
        Remove-Item $fullPath -Confirm:$false -Force
    }
}
