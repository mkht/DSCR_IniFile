DSCR_IniFile
====

PowerShell DSC Resource to create INI file.

## Install
You can install Resource through [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_IniFile/).
```Powershell
Install-Module -Name DSCR_IniFile
```

## Resources
* **cIniFile**
PowerShell DSC Resource to create ini file.

## Properties
### cIniFile
+ [string] **Ensure** (Write):
    + Specify the key exists or not.
    + The default value is Present. (Present | Absent)

+ [string] **Path** (Key):
    + The path of the INI file.

+ [string] **Key** (Key):
    + Key element.

+ [string] **Value** (Required):
    + The value corresponding to the key.

+ [string] **Section** (Key):
    + The section to which the key belongs.
    + **If the key doesn't need to belong section, you should set the value for an empty string.** `""`

+ [string] **Encoding** (Write):
    + You can choose text encoding for the ini file.
    + **UTF8** (default) / UTF7 / UTF32 / Ascii / Unicode / BigEndianUnicode / BigEndianUTF32

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

## ChangeLog
