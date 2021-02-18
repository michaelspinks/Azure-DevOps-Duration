# Azure-DevOps-Duration

Sometimes it is necessary to obtain information about the duration of Azure DevOps pipeline runs.  This cmdlets iterates through pipeline builds and extracts the start and finish time then exports to a csv file the following information:

Pipeline id
Pipeline Name
Build
startTime
finishTime

This information can then be fed into Excel and the date time formatted using a formula such as 

```
=DATE(MID(A1,1,4),MID(A1,6,2),MID(A1,9,2))+TIMEVALUE(MID(A1,12,2)&":"&MID(A1,15,2)&":"&MID(A1,18,6))
```

Where the date you are formatting is in cell A1

Then finishTime - startTime should give you the difference

The run times can then be totalled to understand the business case for using Microsoft-Hosted versus Self-Hosted agents in one example
