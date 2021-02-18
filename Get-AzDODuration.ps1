
# Personal access Token permissions
# Build - Read
# Release - Read

$env:AZURE_DEVOPS_EXT_PAT = '<Your PAT Token>'

#Installs Azure Devops az extension
az extension add --name azure-devops

# The Azure DevOps Organisation
$organisation = "<INSERT your Azure DevOps Organisation>"

# The Azure DevOps Project we are querying
$project = "<INSERT your Azure DevOps Organisation Project>"

# File output path
$filepath = ".\MyOutput.csv"

#Configures Azure DevOps to query organisation and project
az devops configure --defaults organization=$organisation project=$project

# stores list of pipelines in myPipelineList, converts from Json
$myPipelineList =  az pipelines list | ConvertFrom-Json

# Loops through each pipeline in the project
# then loops through all the builds in the pipeline 
# Stores pipeline, pipeline name, build number, finish and start time in $mybuildInformation variable
$mybuildInformation = foreach ($pipeline in $myPipelineList) {
    # Stores builds from each pipeline in myBuildList then loops through them
    $myBuildList = az pipelines runs list --pipeline-ids $pipeline.id | ConvertFrom-Json 
        foreach ($mybuild in $myBuildList) {                 
            [pscustomobject]@{
                Pipeline = $pipeline.id
                PipelineName = $pipeline.name
                Build = $myBuild.buildNumber
                finishTime = $myBuild.finishTime
                startTime = $myBuild.startTime
            }
    }
}

# Outputs pipeline, pipeline name, build number, finish and start time to CSV file
$mybuildInformation | Export-Csv -Path $filepath -NoTypeInformation