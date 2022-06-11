#********************************************************************************
#* Copyright (c) 2021 Contributors to the Eclipse Foundation
#*
#* See the NOTICE file(s) distributed with this work for additional
#* information regarding copyright ownership.
#*
#* This program and the accompanying materials are made available under the
#* terms of the Eclipse Public License 2.0 which is available at
#* http://www.eclipse.org/legal/epl-2.0
#*
#* SPDX-License-Identifier: EPL-2.0
#********************************************************************************/


Function Test-GithubActions
{
    return ($env:GITHUB_ACTIONS -eq "true")
}

Function Enter-LoggingGroup {
    param(
        [Parameter(Position = 0)]
        [string]$Name
    )
    if (Test-GithubActions) {
        Write-Output ("::group::{0}" -f $Name)
    }
}

Function Exit-LoggingGroup {
    if (Test-GithubActions) {
        Write-Output "::endgroup::"
    }
}

Function Write-SdvLogging {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message
    )
    Write-Output ($Message)
}

Function Write-SdvError {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$File,

        [Parameter(Mandatory=$false)]
        [string]$Line,

        [Parameter(Mandatory=$false)]
        [string]$EndLine,

        [Parameter(Mandatory=$false)]
        [string]$Title
    )
    $Parameter = @()

    if (-not [string]::IsNullOrEmpty($File)) {
        $Parameter += ("file={0}" -f $File)
    }

    if (-not [string]::IsNullOrEmpty($Line)) {
        $Parameter += ("line={0}" -f $Line)
    }

    if (-not [string]::IsNullOrEmpty($EndLine)) {
        $Parameter += ("endLine={0}" -f $EndLine)
    }

    if (-not [string]::IsNullOrEmpty($Title)) {
        $Parameter += ("title={0}" -f $Title)
    }

    $ParameterList = $Parameter -join ","

    $ErrorMessage = ("::error {0}::{1}" -f $ParameterList, $Message)
    Write-SdvLogging ($ErrorMessage)
}


Function Start-VehicleAppWithDockerCompose {
    Enter-LoggingGroup "build vehicleApp"
    docker-compose up --build -d 
    Exit-LoggingGroup
    
    Enter-LoggingGroup "get vehicleApp logs"
    Start-Sleep 5
    docker-compose logs
    Exit-LoggingGroup
    
    Enter-LoggingGroup "stopping vehicleApp"
    docker-compose down
    Exit-LoggingGroup
}

Function Start-VehicleAppWithDaprCli {
    Write-SdvLogging ("Starting vehicleApp as job")
    $Job = Start-Job { dapr run --app-id nodeapp --app-port 3000 --dapr-http-port 3500 node examples/SimpleInvoke/receiver/app.js }
    Write-SdvLogging ("Started job {0} ({1})" -f $Job.Id, $Job.Command)
    
    Write-SdvLogging ("Waiting for the application to start")
    do {
        $Applications = dapr list -o json | ConvertFrom-Json
        $ApplicationCount = ($Applications | Measure-Object).Count
        Write-SdvLogging ("Found '{0}' application(s): '{1}'" -f $ApplicationCount, ($Applications.appId -join "', '"))
    } until ($Applications.appId -contains "nodeapp")
    Write-SdvLogging ("Sending new order")
    dapr invoke --app-id nodeapp --method neworder --data-file examples/SimpleInvoke/receiver/sample.json   
    
    Write-SdvLogging ("Stopping vehicleApp")
    dapr stop --app-id nodeapp   
    
    Enter-LoggingGroup "job output"
    Write-SdvLogging "Getting job output "
    Write-SdvLogging "## Job output start ########################################################################################################################"
    $Job | Wait-Job | Receive-Job
    Write-SdvLogging "## Job output end ##########################################################################################################################"
    Exit-LoggingGroup
    
    Write-SdvLogging "## Removing job"
    Write-SdvLogging "List of jobs before remove"
    Get-Job
    Write-SdvLogging ("Removing job {0}" -f $Job.Id)
    $Job | Remove-Job
    Write-SdvLogging "List of jobs after remove"
    Get-Job
}

Function Start-SdvComponent {
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Folder,
        
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$StartProgram,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ProgrammingLanguage,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$Port,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Boolean]$IsPublisher
    )

    process {
        Enter-LoggingGroup ("Starting component {0} as background job" -f $Name)
        Write-SdvLogging ("Program path is: {0}" -f $ProgramPath)
        if ($IsPublisher) {
            $CommandLine = "dapr run --app-id $Name --components-path .dapr/components --config ./.dapr/config.yaml --app-protocol grpc --app-port $Port $ProgrammingLanguage $Folder/$StartProgram"
        }
        else {
            $CommandLine = "dapr run --app-id $Name --components-path .dapr/components --config ./.dapr/config.yaml --app-protocol grpc --dapr-grpc-port=$Port $ProgrammingLanguage $Folder/$StartProgram"
        }
        Write-SdvLogging ("Starting component {0} on port {1} with command line '{2}'" -f $Name, $Port, $CommandLine)
        $ComponentScriptBlock = [scriptblock]::Create($CommandLine)
        $Job = Start-Job -Name $Name -ScriptBlock $ComponentScriptBlock   
        
        Write-SdvLogging ("Started backgound job {0} to run dapr app '{1}'. Command line was: {2}" -f $Job.Id, $Name, $Job.Command)
        
        Write-SdvLogging ("Waiting for $Name to start")
        do {
            $Applications = dapr list -o json | ConvertFrom-Json
            $JobState = ($Job | Get-Job).State
            Write-SdvLogging ("Background job state is '{0}'. Waiting for dapr app '{1}' to start. Currently running dapr apps(s): '{2}'" -f $JobState, $Name, ($Applications.appId -join "', '"))
            if ($JobState -in  @("Completed", "Failed")) {
                $ApplicationHasStopped = $true
            }
            $ApplicationIsRunning = $Applications.appId -contains $Name
        } until ($ApplicationHasStopped -or $ApplicationIsRunning)    
        Exit-LoggingGroup
    }
}

Function Stop-SdvComponent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $Name
    )

    process {
        Enter-LoggingGroup ("Stopping component {0}" -f $Name)
        dapr stop --app-id $Name
        Exit-LoggingGroup

        Enter-LoggingGroup ("Job output ({0})" -f $Name)
        Write-SdvLogging "Getting job output "
        Write-SdvLogging "## Job output start ########################################################################################################################"
        Get-Job $Name | Wait-Job | Receive-Job
        Write-SdvLogging "## Job output end ##########################################################################################################################"
        Exit-LoggingGroup
    
        Enter-LoggingGroup ("Removing job ({0})" -f $Name)
        Write-SdvLogging "List of jobs before remove"
        Get-Job
        Write-SdvLogging ("Removing job {0}" -f $Name)
        Get-Job $Name | Remove-Job
        Write-SdvLogging "List of jobs after remove"
        Get-Job
        Exit-LoggingGroup
    }
}

Function Find-SdvVehicleApp {
    param(
        [Parameter(ParameterSetName = "WithBaseFolder")]
        [Parameter(ParameterSetName = "FilterByName", Mandatory = $false)]
        [string]$BaseFolder = ".",

        [Parameter(ParameterSetName = "FilterByName", Mandatory = $true)]
        [string]$Name,

        [Parameter(ParameterSetName = "WithBaseFolder", Mandatory = $false)]
        [Parameter(ParameterSetName = "FilterByName", Mandatory = $false)]
        [switch]$Recurse
     )

    $Configurations = Get-ChildItem -Path $BaseFolder -Filter "vehicleApp.json" -Recurse:$Recurse | Import-SdvVehicleAppConfiguration
    switch ($PsCmdlet.ParameterSetName) {
        "FilterByName" {
            $Configurations = $Configurations | Where-Object { $_.Name -eq $Name }
        }
    }
    return $Configurations
}

Function Get-SdvComponentProgrammingLanguage {
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Folder,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Name
    )

    if (-not (Test-Path $Folder)) {
        Write-Verbose ("Failed to find folder '{0}'. Returning 'unkown' as programming language." -f $Folder)
        return "unknown"
    }
    $NumberOfNodeJSFiles = (Get-ChildItem $Folder -Filter "*.js" | Measure-Object).Count
    Write-Verbose ("Found '{0}' *.js files in folder '{0}'" -f $NumberOfNodeJSFiles, $Folder)

    $NumberOfPythonFiles = (Get-ChildItem $Folder -Filter "*.py" | Measure-Object).Count
    Write-Verbose ("Found '{0}' *.py files in folder '{0}'" -f $NumberOfNodeJSFiles, $Folder)

    if (($NumberOfNodeJSFiles -gt 0) -and ($NumberOfPythonFiles -eq 0)) {
        $ProgrammingLanguage = "node"
    }
    if (($NumberOfPythonFiles -gt 0) -and ($NumberOfNodeJSFiles -eq 0)) {
        $ProgrammingLanguage = "python3"
    }
    Write-Verbose ("Returning '{0}' as programming language." -f $ProgrammingLanguage)
    return $ProgrammingLanguage
}

Function Import-SdvVehicleAppConfiguration {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]$Fullname
    )

    process {
        Write-Verbose ("Importing vehicleApp configuration from '{0}'" -f $Fullname)
        $Configuration = Get-Content $Fullname | ConvertFrom-Json -Depth 10 

        $RootFolder = Split-Path $Fullname -Parent
        Write-Verbose ("Adding '{0}' as root folder" -f $RootFolder)
        $Configuration | Add-Member -MemberType NoteProperty -Name 'RootFolder' -Value $RootFolder  
        
        foreach ($Component in $Configuration.Components ) {
            Write-Verbose ("Processing component in folder '{0}'" -f $Component.Folder)

            if ([string]::IsNullOrEmpty($Component.Name)) {
                Write-Verbose ("Component name not provided in configuration. Setting component name to folder name '{0}'" -f $Component.Folder)
                $Component | Add-Member -MemberType NoteProperty -Name "Name" -Value $Component.Folder
            }
            Write-Verbose ("Processing component '{0}'" -f $Component.Name)

            Write-Verbose ("Combining vehicleApp root folder '{0}' and component folder '{0}' to get full name.")
            $Component.Folder = Join-Path $RootFolder -ChildPath $Component.Folder 
            Write-Verbose ("Full component folder name is '{0}'" -f $Component.Folder)

            $ProgrammingLanguage = $Component | Get-SdvComponentProgrammingLanguage
            $Component | Add-Member -MemberType NoteProperty -Name "ProgrammingLanguage" -Value $ProgrammingLanguage
            if ([string]::IsNullOrEmpty($Component.StartProgram)) {
                Write-Verbose ("Component start program not provided in configuration. Using auto detect.")
                switch ($Component.ProgrammingLanguage) {
                    "node" { 
                        $StartProgram = ($Component.Name + ".js")
                    }
                    "python3" {
                        $StartProgram = ($Component.Name + ".py")
                    }
                    Default {}
                }
                if (Test-Path (Join-Path $Component.Folder -ChildPath $StartProgram)) {
                    Write-Verbose ("Found start program '{0}'" -f $StartProgram)
                    $Component | Add-Member -MemberType NoteProperty -Name "StartProgram" -Value $StartProgram
                }
                if ([string]::IsNullOrEmpty($Component.StartProgram)) {
                    Write-Verbose ("Warning. Component '{0}' has no start program configured and auto detect did not find a start program.")
                }
            }
            if ([string]::IsNullOrEmpty($Component.DockerFolder)) {
                Write-Verbose ("Docker folder not provided in configuration. Setting docker folder to component folder'{0}'" -f $Component.Folder)
                $Component | Add-Member -MemberType NoteProperty -Name "DockerFolder" -Value $Component.Folder
            }
        }  
        
        return $Configuration
    }
}

Function Get-SdvComponent {
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PSCustomObject]$Components
    )
    process {
        return $Components
    }
}

Function Initialize-SdvComponent {
    param(
        [Parameter(ParameterSetName = "FromComponent", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Folder,

        [Parameter(ParameterSetName = "FromComponent", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ProgrammingLanguage
    )

    process {
        Write-Verbose ("Changing to component folder '{0}'" -f $Folder)
        Push-Location $Folder
        switch ($ProgrammingLanguage) {
            "node" { 
                Write-Verbose ("--------------------------------------------------------")
                Write-Verbose ("Running 'npm install'")
                npm install
                Write-Verbose ("--------------------------------------------------------")
            }
            "python3" {
                Write-Verbose ("--------------------------------------------------------")
                if (Test-Path "./requirements.txt") {
                    Write-Verbose ("Running 'pip3 install -r ./requirements.txt'")
                    pip3 install -r ./requirements.txt 
                } else {
                    Write-Verbose ("Failed to find requirements.txt in component folder. Falling back to requirements.txt in vehicleApp folder")
                    Write-Verbose ("Running 'pip3 install -r ../requirements.txt'")
                    pip3 install -r ../requirements.txt 
                }
                Write-Verbose ("--------------------------------------------------------")
            }
            Default {}
        }
        Pop-Location
    }
}

Function Start-SdvVehicleApp
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name
    )

    Find-SdvVehicleApp -Name $Name  | Get-SdvComponent | Start-SdvComponent
}

Function Stop-SdvVehicleApp
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name
    )

    Find-SdvVehicleApp -Name $Name  | Get-SdvComponent | Stop-SdvComponent
}