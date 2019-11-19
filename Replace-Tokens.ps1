[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$RootFolder,
 
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]$FileName
)
 
function Replace-Tokens
{
    [CmdletBinding()]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$FileFullName
    )
 
    Write-Verbose &quot;Replace tokens in '$FileFullName'...&quot;
 
    # get the environment variables
    $vars = Get-ChildItem -Path env:*
 
    # read in the setParameters file
    $contents = Get-Content -Path $FileFullName
 
    # perform a regex replacement
    $newContents = &quot;&quot;
    $contents | ForEach-Object {
 
        $line = $_
        if ($_ -match &quot;__(\w+)__&quot;) {
            $setting = $vars | Where-Object { $_.Name -eq $Matches[1]  }
 
            if ($setting) {
                Write-Verbose &quot;Replacing key '$($setting.Name)' with value '$($setting.Value)' from environment&quot;
                $line = $_ -replace &quot;__(\w+)__&quot;, $setting.Value
            }
        }
 
        $newContents += $line + [Environment]::NewLine
    }
 
    Write-Verbose -Verbose &quot;Save content to '$FileFullName'.&quot;
    Set-Content $FileFullName -Value $newContents
 
    Write-Verbose &quot;Done&quot;
}
 
Write-Verbose &quot;Look for file '$FileName' in '$RootFolder'...&quot;
 
$files = Get-ChildItem -Path $RootFolder -Recurse -Filter $FileName
 
Write-Verbose &quot;Found $($files.Count) files.&quot;
 
$files | ForEach-Object { Replace-Tokens -FileFullName $_.FullName }
 
Write-Verbose &quot;All files processed.&quot;