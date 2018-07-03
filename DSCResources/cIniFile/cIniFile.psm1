﻿Enum Ensure{
    Absent
    Present
}


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Key,

        [parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [System.String]
        $Value = '',

        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Section = '_ROOT_',

        [parameter()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = 'UTF8'
    )

    if (-not $Section) {$Section = '_ROOT_'}
    [string]$tmpValue = ''

    # check file exists
    if (-not (Test-Path $Path -PathType Leaf)) {
        Write-Verbose ('File "{0}" not found.' -f $Path)
        $Ensure = [Ensure]::Absent
    }
    else {
        #Load ini file
        $Ini = Get-IniFile -Path $Path -Encoding $Encoding

        # if $key is empty, only check section
        if (-not $Key) {
            if ($Ini.$Section) {
                Write-Verbose ('Desired Section found ([{0}])' -f $Section)
                $Ensure = [Ensure]::Present
            }
            else {
                Write-Verbose ('Desired Section NOT found ([{0}])' -f $Section)
                $Ensure = [Ensure]::Absent
            }
        }
        # check section and key exists
        elseif ($Ini.$Section.Contains($Key)) {
            # check value
            Write-Verbose ('Current KVP (Key:"{0}"; Value:"{1}"; Section:"{2}")' -f $Key, $tmpValue, $Section)
            $Ensure = [Ensure]::Present
            $tmpValue = $Ini.$Section.$Key
        }
        else {
            Write-Verbose ('Desired Key or Section not found.')
            $Ensure = [Ensure]::Absent
        }
    }

    $returnValue = @{
        Ensure  = $Ensure
        Path    = $Path
        Key     = $Key
        Value   = $tmpValue
        Section = $PSBoundParameters.Section
    }

    $returnValue
} # end of Get-TargetResource


function Set-TargetResource {
    param
    (
        [parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Key,

        [parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [System.String]
        $Value = '',

        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Section = '_ROOT_',

        [parameter()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = 'UTF8'
    )

    if (-not $Section) {$Section = '_ROOT_'}

    # Ensure = "Absent"
    if ($Ensure -eq [Ensure]::Absent) {
        if (Test-Path $Path) {
            Write-Verbose ("Remove Key:{0}; Section:{1} from '{2}'" -f $Key, $Section, $Path)
            $content = Get-IniFile -Path $Path -Encoding $Encoding | Remove-IniKey -Key $Key -Section $Section -PassThru | Out-IniString
            $content | Out-File -FilePath $Path -Encoding $Encoding -Force
        }
    }
    else {
        # Ensure = "Present"
        $Ini = [ordered]@{}
        if (Test-Path $Path) {
            $Ini = Get-IniFile -Path $Path -Encoding $Encoding
        }
        else {
            Write-Verbose ("Create new file '{0}'" -f $Path)
            New-Item $Path -ItemType File -Force
        }
        $content = $Ini | Set-IniKey -Key $Key -Value $Value -Section $Section -PassThru | Out-IniString
        $content | Out-File -FilePath $Path -Encoding $Encoding -Force
    }
} # end of Set-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Key,

        [parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [System.String]
        $Value = '',

        [parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Section = '_ROOT_',

        [parameter()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = 'UTF8'
    )

    if (-not $Section) {$Section = '_ROOT_'}

    $Ret = ($Ensure -eq [Ensure]::Present)


    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        $Ret = !$Ret
    }
    else {
        $ini = Get-IniFile -Path $Path -Encoding $Encoding

        if ($ini.$Section) {
            if ($ini.$Section.Contains($Key)) {
                if ($Value -ceq $ini.$Section.$Key) {
                    $Ret = $Ret
                }
                else {
                    $Ret = $false
                }
            }
            else {
                $Ret = !$Ret
            }
        }
        else {
            $Ret = !$Ret
        }
    }

    if ($Ret) {
        Write-Verbose ('Test Passed. Nothing needs to do')
    }
    else {
        Write-Verbose "Test NOT Passed."
    }
    
    return $Ret
} # end of Test-TargetResource


function Get-IniFile {
    [CmdletBinding()]
    param
    (
        # Set Target full path to INI
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [validateScript( {Test-Path $_})]
        [Alias('File')]
        [string]
        $Path,

        # specify file encoding
        [Parameter()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding = "ASCII"
    )

    process {
        # Write-Verbose ("Loading file from {0}" -f $Path)
        $Content = Get-Content -Path $Path -Encoding $Encoding
        $CurrentSection = '_ROOT_'
        [System.Collections.Specialized.OrderedDictionary]$IniHash = [ordered]@{}
        $IniHash.Add($CurrentSection, [ordered]@{})

        foreach ($line in $Content) {
            $line = $line.Trim()
            if ($line -match '^;') {
                # Write-Verbose ("Comment")
                $line = ($line.split(';')[0]).Trim()
            }

            if ($line -match '^\[(.+)\]') {
                # Section
                $CurrentSection = $Matches[1]
                if (-not $IniHash.Contains($CurrentSection)) {
                    # Write-Verbose ('Add Section. Section: {0}' -f $Matches[1])
                    $IniHash.Add($CurrentSection, [ordered]@{})
                }
            }
            elseif ($line -match '=') {
                #KeyValuePair
                $idx = $line.IndexOf('=')
                [string]$key = $line.Substring(0, $idx)
                [string]$value = $line.Substring($idx + 1)
                # Write-Verbose ('Add KVP. Key: {0}, Value: {1}, Section: {2}' -f $key,$value,$CurrentSection)
                $IniHash.$CurrentSection.$key = $value
            }
        }
        $IniHash
    }
}

function Out-IniString {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [System.Collections.Specialized.OrderedDictionary]
        $InputObject
    )

    Process {
        [string[]]$IniString = @()
        if ($InputObject.Contains('_ROOT_')) {
            if ($InputObject.'_ROOT_' -as [hashtable]) {
                $private:Keys = $InputObject.'_ROOT_'
                $Keys.Keys.ForEach( {
                        $IniString += ('{0}={1}' -f $_, $Keys.$_)
                    })
            }
        }

        foreach ($Section in $InputObject.keys) {
            if (-not ($Section -eq '_ROOT_')) {
                if ($InputObject.$Section -as [hashtable]) {
                    $IniString += ('[{0}]' -f $Section)
                    $private:Keys = $InputObject.$Section
                    $Keys.Keys.ForEach( {
                            $IniString += ('{0}={1}' -f $_, $Keys.$_)
                        })
                }
            }
        }
        $IniString
    }

}


function Set-IniKey {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [System.Collections.Specialized.OrderedDictionary]
        $InputObject,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Key,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Value = '',

        [Parameter()]
        [string]$Section = '_ROOT_',

        [switch]$PassThru
    )

    Process {
        if ($InputObject.Contains($Section)) {
            if ($Key) {
                if ($InputObject.$Section.Contains($Key)) {
                    Write-Verbose ("Update value. Key:'{0}'; Value:'{1}'; Section:'{2}'" -f $key, $Value, $Section)
                    $InputObject.$Section.$Key = $Value
                }
                else {
                    Write-Verbose ("Set value. Key:'{0}'; Value:'{1}'; Section:'{2}'" -f $key, $Value, $Section)
                    $InputObject.$Section.Add($Key, $Value)
                }
            }
        }
        else {
            $InputObject.Add($Section, [System.Collections.Specialized.OrderedDictionary]@{})
            if ($Key) {
                Write-Verbose ("Set value. Key:'{0}'; Value:'{1}'; Section:'{2}'" -f $key, $Value, $Section)
                $InputObject.$Section.Add($Key, $Value)
            }
        }

        if ($PassThru) {
            $InputObject
        }
    }
}


function Remove-IniKey {
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [System.Collections.Specialized.OrderedDictionary]
        $InputObject,

        [parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Key,

        [parameter()]
        [string]$Section = '_ROOT_',

        [switch]$PassThru
    )

    Process {
        if ($InputObject.Contains($Section)) {
            if ($Key) {
                if ($InputObject.$Section.Contains($Key)) {
                    $InputObject.$Section.Remove($key)
                }
            }
            else {
                $InputObject.Remove($Section)
            }
        }

        if ($PassThru) {
            $InputObject
        }
    }
}

Export-ModuleMember -Function *-TargetResource
