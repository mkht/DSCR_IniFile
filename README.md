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
## ChangeLog
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
