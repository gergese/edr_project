Get-WinEvent -LogName Application | 
ForEach-Object {
    $_ | Select-Object -Property @{
        Name = "EventId"; Expression = { $_.Id }
    }, @{
        Name = "Version"; Expression = { $_.Version }
    }, @{
        Name = "Qualifiers"; Expression = { $_.Qualifiers }
    }, @{
        Name = "Level"; Expression = { $_.Level }
    }, @{
        Name = "Task"; Expression = { $_.Task }
    }, @{
        Name = "Opcode"; Expression = { $_.Opcode }
    }, @{
        Name = "Keywords"; Expression = { $_.Keywords }
    }, @{
        Name = "RecordId"; Expression = { $_.RecordId }
    }, @{
        Name = "ProviderName"; Expression = { $_.ProviderName }
    }, @{
        Name = "ProviderId"; Expression = { $_.ProviderId.Guid }
    }, @{
        Name = "LogName"; Expression = { $_.LogName }
    }, @{
        Name = "ProcessId"; Expression = { $_.ProcessId }
    }, @{
        Name = "ThreadId"; Expression = { $_.ThreadId }
    }, @{
        Name = "MachineName"; Expression = { $_.MachineName }
    }, @{
        Name = "UserId"; Expression = { $_.UserId.Value }
    }, @{
        Name = "TimeCreated"; Expression = { $_.TimeCreated.DateTime }
    }, @{
        Name = "ActivityId"; Expression = { $_.ActivityId.Guid }
    }, @{
        Name = "RelatedActivityId"; Expression = { $_.RelatedActivityId }
    }, @{
        Name = "Properties"; Expression = { $_.Properties }
    }
} | ConvertTo-Json -Depth 10 | Set-Content -Path "D:\script\edr_project\event_logs_filtered.json" -Encoding UTF8
