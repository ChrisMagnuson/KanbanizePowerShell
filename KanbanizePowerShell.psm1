if($env:KanbanizeSubDomain) {
    $script:RootAPIURL = "http://$Env:KanbanizeSubDomain.kanbanize.com/index.php/api/kanbanize"
} else {
    $script:RootAPIURL = "http://www.kanbanize.com/index.php/api/kanbanize"
}

if($Env:KanbanizeAPIKey) {
    $script:Headers = @{"apikey"=$Env:KanbanizeAPIKey}
}

Function Set-KanbanizeResponseFormat {
    param(
        [parameter(Mandatory = $true)]
        [ValidateSet("json","xml")]
        $Format
    )
    $script:Format = $Format
}

Set-KanbanizeResponseFormat json

Function Set-KanbanizeSubDomain {
    param(
        [parameter(Mandatory = $true)]$SubDomain,
        [switch]$Permanent
    )
    
    if ($Permanent) {
        [Environment]::SetEnvironmentVariable( "KanbanizeSubDomain", $SubDomain, "User" )
    }

    $script:RootAPIURL = "http://$SubDomain.kanbanize.com/index.php/api/kanbanize"
}

Function Invoke-KanbanizeLogin {
    param(
        [parameter(Mandatory = $true)]$Email, 
        [parameter(Mandatory = $true)]$Pass,
        [switch]$Permanent
    )
    
    $PSBoundParameters.Remove("Permanent") | Out-Null
    $Response = Invoke-KanbanizeAPIFunction -FunctionName login -Parameters $PSBoundParameters 
    
    if (-not $Response.apikey) { throw "No apikey returned" }

    if ($Permanent) {
        [Environment]::SetEnvironmentVariable( "KanbanizeAPIKey", $Response.apikey, "User" )
    }

    $script:Headers = @{"apikey"=$Response.apikey}
}

function Get-KanbanizeAPIURLWithParametersInURL {
    param(
        [parameter(Mandatory = $true)]$FunctionName, 
        $Parameters = @{}
    )
    $URLEncodedParameters = @{}
    $Parameters.Keys | % { $URLEncodedParameters.Add($_.ToLower(), [Uri]::EscapeDataString($Parameters[$_])) }

    $FormattedParameters = $($URLEncodedParameters.Keys | % { $_ +"/" + $URLEncodedParameters[$_] }) -join "/"

    $URL = $script:RootAPIURL + "/" + $FunctionName 
    if ($FormattedParameters) {
        $URL += "/" + $FormattedParameters
    }
    $URL += "/format/" + $Format
    $URL
}

function Get-KanbanizeAPIURL {
    param(
        [parameter(Mandatory = $true)]$FunctionName
    )
    $URL = $script:RootAPIURL + "/" + $FunctionName 
    $URL += "/format/" + $Format
    $URL
}

function Invoke-KanbanizeAPIFunction {
    param(
        [parameter(Mandatory = $true)]$FunctionName,
        $Parameters = @{}
    )

    $ParametersWithLowerCaseNames = @{}
    
    $Parameters.Keys |
    where {$_ -ne "CustomFields"} | 
    % { 
        $ParametersWithLowerCaseNames.Add(
            $_.ToLower(), 
            [Uri]::EscapeDataString( 
                $(
                    #Kanbanize api requires escaping \ and " with an additional \
                    ($Parameters[$_]  -replace "\\", "\\") -replace '"','\"' 
                )
            )
        ) 
    }
    
    if($Parameters["CustomFields"]) {
        $Parameters["CustomFields"].keys | 
        % { 
            $ParametersWithLowerCaseNames.Add(
                $_.ToLower(), 
                [Uri]::EscapeDataString(
                    $(
                        #Kanbanize api requires escaping \ and " with an additional \
                        ($Parameters["CustomFields"][$_] -replace "\\", "\\") -replace '"','\"'
                    )
                )
            )
        }
    }

    $ParametersWithLowerCaseNamesJson = $ParametersWithLowerCaseNames | ConvertTo-Json

    $URL = Get-KanbanizeAPIURL -FunctionName $FunctionName

    Invoke-RestMethod -Method Post -Uri $URL -Headers $Headers -Body $ParametersWithLowerCaseNamesJson
}

function Invoke-KanbanizeAPIFunctionWithURIEncodedParameters {
    param(
        [parameter(Mandatory = $true)]$FunctionName,
        $Parameters = @{}
    )

    $URLEncodedParameters = @{}
    $Parameters.Keys |
        where {$_ -ne "CustomFields"} | 
        % { $URLEncodedParameters.Add($_.ToLower(), [Uri]::EscapeDataString($Parameters[$_])) }
    
    if($Parameters["CustomFields"]) {
        $Parameters["CustomFields"].keys | 
            % { $URLEncodedParameters.Add($_.ToLower(), $Parameters["CustomFields"][$_]) }
    }

    $URLEncodedParametersJson = $URLEncodedParameters | ConvertTo-Json

    $URL = Get-KanbanizeAPIURL -FunctionName $FunctionName

    Invoke-RestMethod -Method Post -Uri $URL -Headers $Headers -Body $URLEncodedParametersJson
}

function Invoke-KanbanizeAPIFunctionWithParametersInURL {
    param(
        [parameter(Mandatory = $true)]$FunctionName,
        $Parameters = @{}
    )
    $URL = Get-KanbanizeAPIURLWithParametersInURL -FunctionName $FunctionName -Parameters $Parameters
    Invoke-RestMethod -Method Post -Uri $URL -Headers $Headers
}

Function Get-KanbanizeProjectsAndBoards{
    Invoke-KanbanizeAPIFunction get_projects_and_boards
}

Function Get-KanbanizeBoardStructure {
    param(
        [parameter(Mandatory = $true)]$BoardID
    )
    Invoke-KanbanizeAPIFunction -FunctionName get_board_structure -Parameters $PSBoundParameters
}

Function Get-KanbanizeFullBoardStructure {
    param(
        [parameter(Mandatory = $true)]$BoardID
    )
    Invoke-KanbanizeAPIFunction -FunctionName get_full_board_structure -Parameters $PSBoundParameters
}

Function Get-KanbanizeFullBoardSettings {
    param(
        [parameter(Mandatory = $true)]$BoardID
    )
    Invoke-KanbanizeAPIFunction -FunctionName get_board_settings -Parameters $PSBoundParameters
}

Function Get-KanbanizeBoardActivities {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [parameter(Mandatory = $true)][Datetime]$FromDate = (get-date),
        [parameter(Mandatory = $true)][Datetime]$ToDate = (get-date),
        [int]$Page,
        [int]$ResultsPerPage,
        $Author,
        [ValidateSet("Transitions","Updates","Comments","Blocks","All")] 
        $EventType,
        [ValidateSet("plain","html")]$TextFormat
    )


    Invoke-KanbanizeAPIFunction -FunctionName get_board_settings -Parameters $PSBoundParameters
}

Function New-KanbanizeTask {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        $Title,
        $Description,
        $Priority,
        $Assignee,
        $Color,
        $Size,
        $Tags,
        $Deadline,
        $ExtLink,
        $Type,
        $Template,
        [hashtable]$CustomFields,
        $Column,
        $Lane,
        $Position,
        $ExceedingReason,
        $ReturnTaskDetails
    )
    Invoke-KanbanizeAPIFunction -FunctionName create_new_task -Parameters $PSBoundParameters
}

Function Remove-KanbanizeTask {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [parameter(Mandatory = $true)]$TaskID
    )
    Invoke-KanbanizeAPIFunction -FunctionName delete_task -Parameters $PSBoundParameters
}

Function Get-KanbanizeTaskDetails {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [parameter(Mandatory = $true)]$TaskID,
        [ValidateSet("yes")] $History,
        [ValidateSet("move","create","update","block","delete","comment","archived","subtask","loggedtime")]$Event,
        [ValidateSet("plain","html")]$TextFormat
    )
    Invoke-KanbanizeAPIFunction -FunctionName get_task_details -Parameters $PSBoundParameters
}

Function Get-KanbanizeAllTasks {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [ValidateSet("yes")] $Subtasks,
        [ValidateSet("archive")][Parameter(ParameterSetName='Container')]$Container,
        [Parameter(ParameterSetName="Container")]$FromDate,
        [Parameter(ParameterSetName="Container")]$ToDate,
        [Parameter(ParameterSetName="Container")]$Version,
        [Parameter(ParameterSetName="Container")]$Page,
        [ValidateSet("plain","html")]$TextFormat
    )
    Invoke-KanbanizeAPIFunction -FunctionName get_all_tasks -Parameters $PSBoundParameters
}

Function Add-KanbanizeComment {
    param(
        [parameter(Mandatory = $true)]$TaskID,
        $Comment
    )
    Invoke-KanbanizeAPIFunction -FunctionName add_comment -Parameters $PSBoundParameters
}

Function Move-KanbanizeTask {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [parameter(Mandatory = $true)]$TaskID,
        [parameter(Mandatory = $true)]$Column,
        $Lane,
        $Position,
        $ExceedingReason
    )
    Invoke-KanbanizeAPIFunctionWithParametersInURL -FunctionName move_task -Parameters $PSBoundParameters
}

Function Edit-KanbanizeTask {
    param(
        [parameter(Mandatory)]$BoardID,
        [parameter(Mandatory)]$TaskID,
        $Title,
        $Description,
        $Priority,
        $Assignee,
        $Color,
        $Size,
        $Tags,
        $Deadline,
        $ExtLink,
        $Type,
        [hashtable]$CustomFields
    )
    Invoke-KanbanizeAPIFunction -FunctionName edit_task -Parameters $PSBoundParameters
}

Function Block-KanbanizTask {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [parameter(Mandatory = $true)]$TaskID,
        [ValidateSet("block","editblock","unblock")]$Event,
        $BlockReason

    )
    Invoke-KanbanizeAPIFunction -FunctionName block_task -Parameters $PSBoundParameters
}

Function Add-KanbanizeSubTask {
    param(
        [parameter(Mandatory = $true)]$TaskParent,
        $Title,
        $Assignee
    )
    Invoke-KanbanizeAPIFunction -FunctionName add_subtask -Parameters $PSBoundParameters
}

Function Edit-KanbanizeSubTask {
    param(
        [parameter(Mandatory = $true)]$BoardID,
        [parameter(Mandatory = $true)]$SubtaskID,
        $Title,
        $Assignee,
        [ValidateSet(1,0)]$Complete
    )
    Invoke-KanbanizeAPIFunction -FunctionName edit_subtask -Parameters $PSBoundParameters
}

Function Log-KanbanizeTime {
    param(
        [parameter(Mandatory = $true)]$LoggedTime,
        [parameter(Mandatory = $true)]$TaskID,
        $Description
    )
    Invoke-KanbanizeAPIFunction -FunctionName log_time -Parameters $PSBoundParameters
}

Function Get-KanbanizeLinks {
    param(
        [Parameter(ParameterSetName="BoardID")]$BoardID,
        [Parameter(ParameterSetName="TaskID")]$TaskID
    )
    Invoke-KanbanizeAPIFunction -FunctionName get_links -Parameters $PSBoundParameters
}
