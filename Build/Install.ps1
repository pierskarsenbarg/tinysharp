param($installPath, $toolsPath, $package, $project)

function GenerateKey()
{
    return -join(@('A'[0]..'Z'[0];'a'[0]..'z'[0];'0'[0]..'9'[0])|%{[char]$_} | Sort-Object {Get-Random})
}


function UpdateCurrentProjectsConfigFile()
{
    $config = $project.ProjectItems | where {$_.Name -eq "Web.config"}
    if ($config -eq $null)
    {
        $config = $project.ProjectItems | where {$_.Name -eq "App.config"}
        if ($config -eq $null)
        {
            return
        }
    }
    $localPath = $config.Properties | where {$_.Name -eq "LocalPath"}
    UpdateConfigFile $localPath.Value
}

function UpdateConfigFile($configFilePath)
{
    $tinyKey = GenerateKey
    $xml = New-Object XML
    $xml.Load($configFilePath)
	$appSettingNode = $xml.SelectSingleNode("configuration/appSettings/add[@key = 'TinySharpKey']")

    Write-Host $appSettingNode

	If( $appSettingNode -ne $null)
	{
		Write-Host "TinySharpKey already exists in config file"
		return
	}	

    $appSettingsNode = $xml.SelectSingleNode("configuration/appSettings")
    if ($appSettingsNode -eq $null)
    {
        $appSettingsNode = $xml.CreateElement("appSettings")
        $xml.DocumentElement.AppendChild($appSettingsNode)
    }

    if ($tinyKey -ne "")
    {    
        $comment = $xml.CreateComment("TinySharpKey is used to generate the hash. Do not change it once you start using TinySharp or you won't be able to reverse any previously generated hashes.")
        $appSettingsNode.AppendChild($comment)
    }   

    if($appSettingNode -eq $null)
    {
        $keyElement = $xml.CreateElement("add")
        $keyElement.SetAttribute("key", "TinySharpKey")
        $keyElement.SetAttribute("value", "$tinyKey")
        $appSettingsNode.AppendChild($keyElement)
    }

    
    $xml.Save($configFilePath)
}

UpdateCurrentProjectsConfigFile