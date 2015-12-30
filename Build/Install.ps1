param($installPath, $toolsPath, $package, $project)

function GenerateKey()
{
    return -join(@('A'[0]..'Z'[0];'a'[0]..'z'[0];'0'[0]..'9'[0])|%{[char]$_} | Sort-Object {Get-Random})
}


function UpdateCurrentProjectsConfigFile([string]$name)
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
    UpdateConfigFile($localPath.Value, $name)
}

function UpdateConfigFile([string]$configFilePath, [string]$name)
{
Write-Host "configFilePath: " 
Write-Host $configFilePath
	$references = (Select-String $configFilePath -pattern "TinySharpKey").Matches.Count

	If( $references -ne 0)
	{
		Write-Host "TinySharpKey already exists in config file"
		return
	}

	$xml = New-Object xml
    $xml.Load($configFilePath)

	$appSettingNode = $xml.SelectSingleNode("configuration/appSettings/add[@key = 'TinySharpKey']")

	
	Write-Host "Adding TinySharpKey appSetting to " $configFilePath

    $appSettingsNode = $xml.SelectSingleNode("configuration/appSettings")
    if ($appSettingsNode -eq $null)
    {
        $appSettingsNode = $xml.CreateElement("appSettings")
        $xml.DocumentElement.AppendChild($appSettingsNode)
    }

    if ($name -eq "")
    {    
        $comment = $xml.CreateComment("TinySharpKey is used to generate the hash. Do not change it once you start using TinySharp or you won't be able to reverse any previously generated hashes.")
        $appSettingsNode.AppendChild($comment)
    }
    
    $xml.Save($configFilePath)
}

$key = GenerateKey
UpdateCurrentProjectsConfigFile $key