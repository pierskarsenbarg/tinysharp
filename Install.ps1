param($installPath, $toolsPath, $package, $project)

Write-Host "installing my package"

function GenerateKey()
{
    [char[]] $keyArray = @()
    for($i = 65;$i -le 122;$i++) 
    {
        if($i -lt 91 -or $i -gt 96)  
        {
            $keyArray += [char]$i
        }  
    }
    for($i = 0; $i -le 9; $i++)
    {
        $keyArray += ("$i")
    }

    $rndArray = $keyArray | Sort-Object {Get-Random}

    return [string]$rndArray
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