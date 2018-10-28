DSCR_IniFile
====

## This repository is no longer maintained ! :no_entry:
Please use [DSCR_FileContent](https://github.com/mkht/DSCR_FileContent/) module.

----
[![Build status](https://ci.appveyor.com/api/projects/status/2i2u8q4jn9bwgmrd/branch/master?svg=true)](https://ci.appveyor.com/project/mkht/dscr-inifile/branch/master)
[![codecov](https://codecov.io/gh/mkht/DSCR_IniFile/branch/master/graph/badge.svg)](https://codecov.io/gh/mkht/DSCR_IniFile)

PowerShell DSC Resource to create INI file.

## Install
You can install Resource from [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_IniFile/).
```Powershell
Install-Module -Name DSCR_IniFile
```

----
## DSC Resources
* **cIniFile**
PowerShell DSC Resource to create ini file.

## Properties
### cIniFile
+ [string] **Ensure** (Write):
    + Specify the key exists or not.
    + The default value is `Present`. (`Present` | `Absent`)

+ [string] **Path** (Key):
    + The path of the INI file.

+ [string] **Key** (Key):
    + Key element.
    + If you specified key as empty string, cIniFile only check the section.

+ [string] **Value** (Write):
    + The value corresponding to the key.
    + If this param not specified, will set empty string.

+ [string] **Section** (Key):
    + The section to which the key belongs.
    + **If the key doesn't need to belong section, you should set the value for an empty string.**

+ [string] **Encoding** (Write):
    + You can choose text encoding for the INI file.
    + `UTF8NoBOM` (default) / `UTF8BOM` / `utf32` / `unicode` / `bigendianunicode` / `ascii`

+ [string] **NewLine** (Write):
    + You can choose new line code for the INI file.
    + `CRLF` (default) / `LF`


## Examples
+ **Example 1**: Sample configuration
```Powershell
Configuration Example1 {
    Import-DscResource -ModuleName DSCR_IniFile
    cIniFile Apple {
        Path = "C:\Test.ini"
        Section = ""
        Key = "Fruit_A"
        Value = "Apple"
    }
    cIniFile Banana {
        Path = "C:\Test.ini"
        Section = ""
        Key = "Fruit_B"
        Value = "Banana"
    }
    cIniFile Ant {
        Path = "C:\Test.ini"
        Section = "Animals"
        Key = "Animal_A"
        Value = "Ant"
    }
}
```

The result of executing the above configuration, the following ini file will output to `C:\Test.ini`
```
Fruit_A=Apple
Fruit_B=Banana
[Animals]
Animal_A=Ant
```

----
## Functions

### Get-IniFile
Load ini file and convert to the dictionary object

+ **Syntax**
```PowerShell
Get-IniFile [-Path] <string> [-Encoding { <utf8> | <utf8BOM> | <utf32> | <unicode> | <bigendianunicode> | <ascii> | <Default> }]
```


### ConvertTo-IniString
Convert dictionary object to ini expression string

+ **Syntax**
```PowerShell
ConvertTo-IniString [-InputObject] <System.Collections.Specialized.OrderedDictionary>
```

+ **Example**
```PowerShell
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> ConvertTo-IniString -InputObject $Dictionary
[Section1]
Key1=Value1
Key2=Value2
```


### Set-IniKey
Set a key value pair to the dictionary

+ **Syntax**
```PowerShell
Set-IniKey [-InputObject] <System.Collections.Specialized.OrderedDictionary> -Key <string> [-Value <string>] [-Section <string>] [-PassThru]
```

+ **Example**
```PowerShell
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> $Dictionary | Set-IniKey -Key 'Key2' -Value 'ModValue2' -Section 'Section1' -PassThru | ConvertTo-IniString
[Section1]
Key1=Value1
Key2=ModValue2
```


### Remove-IniKey
Remove a key value pair from dictionary

+ **Syntax**
```PowerShell
Remove-IniKey [-InputObject] <System.Collections.Specialized.OrderedDictionary> -Key <string> [-Section <string>] [-PassThru]
```

+ **Example**
```PowerShell
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> $Dictionary | Remove-IniKey -Key 'Key2' -Section 'Section1' -PassThru | ConvertTo-IniString
[Section1]
Key1=Value1
```

----
## ChangeLog
+ **3.1.0**
    - Export useful functions (`Get-IniFile`, `ConvertTo-IniString`, `Set-IniKey`, `Remove-IniKey`)
    - Fix typo in the module name

+ **3.0.1**
    - Fix PSSA issues (PSAvoidTrailingWhitespace)
    - Remove unnecessary files in the published data

+ **3.0.0**
    - **[BREAKING CHANGE]** Default output encoding is changed from `UTF8BOM` to `UTF8NoBOM`

+ **2.0.1**
    - Fixed issue that an incorrect INI file has been created when the encoding other than `UTF8NoBOM` was specified.

+ **2.0.0**
    - Added **NewLine** property for specifying the new line code. (`CRLF` or `LF`)
    - You can now specify `UTF8NoBOM` as Encoding.
    - **[DEPRECATED]** Encoding options `UTF7` and `BigEndianUTF32` have been deprecated.

+ **1.2.0**
    - Check section only when `Key = ""` [#2](https://github.com/mkht/DSCR_IniFile/issues/2)

+ **1.1.1**
    - Fixed issue that does not work correctly when `Ensure = "Absent"` [#1](https://github.com/mkht/DSCR_IniFile/issues/1)
    - `Value` param is no longer mandatory.
