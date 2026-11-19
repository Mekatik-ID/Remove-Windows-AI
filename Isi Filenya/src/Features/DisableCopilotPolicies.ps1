# Disable-Copilot-Policies - Matikan kebijakan Copilot

function Disable-Copilot-Policies {
    #disable copilot policies in region policy json
    $JSONPath = "$env:windir\System32\IntegratedServicesRegionPolicySet.json"
    if (Test-Path $JSONPath) {
        Write-Host "$(@('Disabling','Enabling')[$revert]) CoPilot Policies in " -NoNewline -ForegroundColor Cyan
        Write-Host "[$JSONPath]" -ForegroundColor Yellow

        #takeownership
        takeown /f $JSONPath *>$null
        icacls $JSONPath /grant *S-1-5-32-544:F /t *>$null

        #edit the content
        $jsonContent = Get-Content $JSONPath | ConvertFrom-Json
        try {
            $copilotPolicies = $jsonContent.policies | Where-Object { $_.'$comment' -like '*CoPilot*' }
            foreach ($policies in $copilotPolicies) {
                $policies.defaultState = @('disabled', 'enabled')[$revert]
            }
            $recallPolicies = $jsonContent.policies | Where-Object { $_.'$comment' -like '*A9*' -or $_.'$comment' -like '*Manage Recall*' -or $_.'$comment' -like '*Settings Agent*' }
            foreach ($recallPolicy in $recallPolicies) {
                if ($recallPolicy.'$comment' -like '*A9*') {
                    $recallPolicy.defaultState = @('enabled', 'disabled')[$revert]
                }
                elseif ($recallPolicy.'$comment' -like '*Manage Recall*') {
                    $recallPolicy.defaultState = @('disabled', 'enabled')[$revert]
                }
                elseif ($recallPolicy.'$comment' -like '*Settings Agent*') {
                    $recallPolicy.defaultState = @('enabled', 'disabled')[$revert]
                }
            }
            $newJSONContent = $jsonContent | ConvertTo-Json -Depth 100
            Set-Content $JSONPath -Value $newJSONContent -Force
            $total = ($copilotPolicies.count) + ($recallPolicies.count)
            Write-Status -msg "$total CoPilot Policies $(@('Disabled','Enabled')[$revert])"
        }
        catch {
            Write-Status -msg 'CoPilot Not Found in IntegratedServicesRegionPolicySet' -errorOutput 
        }

    
    }

    #additional json path for visual assist 
    $visualAssistPath = "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\VisualAssist\VisualAssistActions.json"
    if (Test-Path $visualAssistPath) {
        Write-Status -msg "$(@('Disabling','Enabling')[$revert]) Generative AI in Visual Assist..."

        takeown /f $visualAssistPath *>$null
        icacls $visualAssistPath /grant *S-1-5-32-544:F /t *>$null

        $jsoncontent = Get-Content $visualAssistPath | ConvertFrom-Json
        $jsonContent.actions | Add-Member -MemberType NoteProperty -Name usesGenerativeAI -Value @($false, $true)[$revert] -force
        $newJSONContent = $jsonContent | ConvertTo-Json -Depth 100
        Set-Content $visualAssistPath -Value $newJSONContent -Force
    }
    
}
