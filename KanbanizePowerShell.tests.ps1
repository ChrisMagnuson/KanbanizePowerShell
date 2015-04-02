Import-Module KanbanizePowershell -Force

$Email = "cmagnuson@tervis.com"
$Password = "BobBillJoe1"
$SubDomain = "tervis"
$TestBoardID = 23
$UserName = "Chris Magnuson"

Describe "Set-KanbanizeSubDomain" {
    it "Sets subdomain used for your Kanbanize api URL" {
        Set-KanbanizeSubDomain $SubDomain
    }
}

Describe "Invoke-KanbanizeLogin" {
    it "Logs in" {
        Invoke-KanbanizeLogin -Email $Email -Pass $Password
    }
}

Describe "Get-KanbanizeProjectsAndBoards" {
    it "Gets list of kanbanize projectds and boards" {
        Get-KanbanizeProjectsAndBoards
    }
}

Describe "Get-KanbanizeBoardStructure" {
    it "Gets structure of the first board returned by Get-KanbanizeProjectsAndBoards" {
        Get-KanbanizeBoardStructure -BoardID $( $(Get-KanbanizeProjectsAndBoards).projects.boards.id | select -First 1 ) 
    }
}

Describe "Get-KanbanizeFullBoardSettings" {
    it "Gets list of kanbanize projectds and boards" {
        Get-KanbanizeFullBoardSettings -BoardID $( $(Get-KanbanizeProjectsAndBoards).projects.boards.id | select -First 1 )
    }
}

Describe "New-KanbanizeTask" {

    it "Create a new task with basic title" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Title "Test title"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.title | should be "Test title"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }

    it "Create a new task with basic title in the In Progress column" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Title "Test title" -Column "In Progress"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.title | should be "Test title"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }


    it "Create a new task with advanced title" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Title "Check out http://www.kanbanize.com/thisthing?stuff=something"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.title | should be "Check out http://www.kanbanize.com/thisthing?stuff=something"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }

    it "Create a new task with basic description" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Description "Basic Description"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.description | should be "Basic Description"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }

    it "Create a new task with advanced description" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Description "Advanced http://www.kanbanize.com/thisthing?stuff=something"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.description | should be "Advanced http://www.kanbanize.com/thisthing?stuff=something"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }

    it "Create a new task with assignee without a space in their name" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Assignee "TestUser"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.assignee | should be "TestUser"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }
 
    it "Create a new task with assignee with a space in their name" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Assignee "Test User"
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.assignee | should be "Test User"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }

    it "Create a new task with custom property trackitid" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -CustomFields @{"trackitid"=1234}
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.customfields | where name -EQ trackitid | select -ExpandProperty value | should be "1234"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }

   it "Create a new task with template P2" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Title "Task 1234" -Template P2
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.priority | should be "high" #based on the template being used
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }
    
    it "Create a new task with custom property trackiturl" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -CustomFields @{"trackiturl"="http://trackit/TTHelpdesk/Application/Main?tabs=w68316"}
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.customfields | where name -EQ trackiturl | select -ExpandProperty value | should be "http://trackit/TTHelpdesk/Application/Main?tabs=w68316"
        Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id
    }
<#    it "Create a new task with advanced title" {
        New-KanbanizeTask -BoardID $TestBoardID -Title "Check out http://www.kanbanize.com"
    }
    it "" {
    }
    it "" {
    }
    it "" {
    }
    it "" {
    }
    it "" {
    }
    it "" {
    }#>

}

Describe "Move-KanbanizeTask" {
    it "Moves Kanbanize task between columns" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Title "Check out http://www.kanbanize.com/thisthing?stuff=something" -Description "Advanced http://www.kanbanize.com/thisthing?stuff=something" -Assignee "Test User" -CustomFields @{"trackitid"=68316;"trackiturl"="http://trackit/TTHelpdesk/Application/Main?tabs=w68316"}

    }
}

Describe "Get-KanbanizeTaskDetails" {
    it "Gets list of kanbanize projectds and boards" {
    }
}

Describe "Add-KanbanizeComment" {
    it "Gets list of kanbanize projectds and boards" {
    }
}

Describe "Edit-KanbanizeTask" {
    it "Edit the title of a kanbanize task" {
        $NewTaskResult = New-KanbanizeTask -BoardID $TestBoardID -Title "Check out http://www.kanbanize.com/thisthing?stuff=something" -Description "Advanced http://www.kanbanize.com/thisthing?stuff=something" -Assignee "Test User" -CustomFields @{"trackitid"=68316;"trackiturl"="http://trackit/TTHelpdesk/Application/Main?tabs=w68316"}
        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        
        $TaskDetails.title | should be "Check out http://www.kanbanize.com/thisthing?stuff=something"
        $TaskDetails.description | should be "Advanced http://www.kanbanize.com/thisthing?stuff=something"
        $TaskDetails.assignee | should be "Test User"
        $TaskDetails.customfields | where name -EQ trackitid | select -ExpandProperty value | should be "68316"
        $TaskDetails.customfields | where name -EQ trackiturl | select -ExpandProperty value | should be "http://trackit/TTHelpdesk/Application/Main?tabs=w68316"

        Edit-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id -Title "something totally different http://www.google.com" -Description "Advanced http://google.com description" -CustomFields @{"trackitid"=1234;"trackiturl"="http://trackit/TTHelpdesk/Application/Main?tabs=w1234"}

        $TaskDetails = Get-KanbanizeTaskDetails -BoardID $TestBoardID -TaskID $NewTaskResult.id
        $TaskDetails.title | should be "something totally different http://www.google.com"
        $TaskDetails.description | should be "Advanced http://google.com description"
        $TaskDetails.customfields | where name -EQ trackitid | select -ExpandProperty value | should be "1234"
        $TaskDetails.customfields | where name -EQ trackiturl | select -ExpandProperty value | should be "http://trackit/TTHelpdesk/Application/Main?tabs=w1234"

        #Remove-KanbanizeTask -BoardID $TestBoardID -TaskID $NewTaskResult.id 
    }
}
