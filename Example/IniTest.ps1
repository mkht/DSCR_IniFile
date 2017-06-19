$output = 'C:\IniTest\MOF'

Configuration IniTest
{
    Import-DscResource -ModuleName DSCR_IniFIle
    Node localhost
    {
        cIniFile IniTest
        {
            Ensure = "Present"
            Path = "C:\IniTest.ini"
            Key = 'TestKey'
            Value = 'TestValue'
            Section = 'Section'
            Encoding = 'UTF8'
        }  
    }
}

IniTest -OutputPath $output
Start-DscConfiguration -Path  $output -Verbose -wait

