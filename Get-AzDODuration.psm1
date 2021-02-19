Function Get-AZDODuration {
    <#
.SYNOPSIS
    This script connects to an Azure DevOps Organisation and iterates through the Pipelines therein, outputting the start finish times of build runs

.NOTES
    Name: Mike Spinks
    Version: 1.0
    DateCreated: 2021-02-18

    This version Relies upon 

    Personal access Token permissions Build - Read; and Release - Read
    $env:AZURE_DEVOPS_EXT_PAT = '<Your PAT Token>'

.EXAMPLE
    Get-AzDODuration -Organization "MyOrg" -Project "myProject"

#>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $false,
            Position = 0
        )]
        [string]$Organization,
        [string]$Project,
        [string]$filepath = '.\MyOutput.csv'


    )

    # Checks for the presence of the $env:AZURE_DEVOPS_EXT_PAT being set.  Terminates if missing

    try {
        Get-childitem -Path Env:\AZURE_DEVOPS_EXT_PAT -ErrorAction Stop | Select-Object -Property Name -ErrorAction Stop
    }
    catch {
        Write-Host $PSItem.Exception.Message -ForegroundColor Red
    }

    # Checks for the presence of the azure-devops az extension.  Terminates if missing
    try {
        $ErrorActionPreference = "Stop"
        az extension show --name azure-devops
        $ErrorActionPreference = "Continue"
    }
    catch {
        Write-Host $PSItem.Exception.Message -ForegroundColor Red
        Exit
    }
        
    #Configures Azure DevOps to query organisation and project
    az devops configure --defaults organization=$Organization project=$Project

    # Checks it is possible to retrieve list of Pipelines
    # stores list of pipelines in myPipelineList, converts from Json
    try {
        $ErrorActionPreference = "Stop"
        $myPipelineList = az pipelines list | ConvertFrom-Json
        $ErrorActionPreference = "Continue"
    }
    catch {
        Write-Warning "Unable to retrieve the list of Azure DevOps Pipelines successfully"
        Exit
    }
    finally {
        $Error.Clear()
    }
        
    # Loops through each pipeline in the project
    # then loops through all the builds in the pipeline 
    # Stores pipeline, pipeline name, build number, finish and start time in $mybuildInformation variable
    $mybuildInformation = foreach ($pipeline in $myPipelineList) {
        # Stores builds from each pipeline in myBuildList then loops through them
        $myBuildList = az pipelines runs list --pipeline-ids $pipeline.id | ConvertFrom-Json 
        foreach ($mybuild in $myBuildList) {                 
            [pscustomobject]@{
                Pipeline     = $pipeline.id
                PipelineName = $pipeline.name
                Build        = $myBuild.buildNumber
                startTime    = $myBuild.startTime
                finishTime   = $myBuild.finishTime
            }
        }
    }

    # Outputs pipeline, pipeline name, build number, finish and start time to CSV file
    $mybuildInformation | Export-Csv -Path $filepath -NoTypeInformation

}