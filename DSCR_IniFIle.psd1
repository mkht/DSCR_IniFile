@{
    # Version number of this module.
    ModuleVersion        = '3.0.1'

    # ID used to uniquely identify this module
    GUID                 = '372ae78d-ef58-4c3d-8df7-987d07f9a1c2'

    # Author of this module
    Author               = 'mkht'

    # Company or vendor of this module
    CompanyName          = ''

    # Description of the functionality provided by this module
    Copyright            = '(c) 2018 mkht. All rights reserved.'

    # Copyright statement for this module
    Description          = 'PowerShell DSC Resource to create INI file.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Functions to export from this module
    FunctionsToExport    = @()

    # Cmdlets to export from this module
    CmdletsToExport      = @()

    # Aliases to export from this module
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport = @('cIniFile')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = ('DesiredStateConfiguration', 'DSC', 'DSCResource', 'INI')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/mkht/DSCR_IniFile/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/mkht/DSCR_IniFile'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}

