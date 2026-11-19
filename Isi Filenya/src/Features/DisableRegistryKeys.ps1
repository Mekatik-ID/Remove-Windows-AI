# Disable-Registry-Keys - Matikan fitur AI lewat Registry

function Disable-Registry-Keys {
    #maybe add params for particular parts

    #disable ai registry keys
    Write-Status -msg "$(@('Disabling', 'Enabling')[$revert]) Copilot and Recall..."
    <#
    #new keys related to windows ai schedled task 
    #npu check 
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'HardwareCompatibility' /t REG_DWORD /d '0' /f 
    #dont know
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'ITManaged' /t REG_DWORD /d '0' /f
    #enabled by windows ai schedled task 
    #set to 1 in the us 
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'AllowedInRegion' /t REG_DWORD /d '0' /f
    #enabled by windows ai schelded task 
    # policy enabled = 1 when recall is enabled in group policy 
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'PolicyConfigured' /t REG_DWORD /d '0' /f
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'PolicyEnabled' /t REG_DWORD /d '0' /f
    #dont know
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'FTDisabledState' /t REG_DWORD /d '0' /f
    #prob the npu check failing
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'MeetsAdditionalDriverRequirements' /t REG_DWORD /d '0' /f
    #sucess from last run 
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'LastOperationKind' /t REG_DWORD /d '2' /f
    #doesnt install recall for me so 0
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'AttemptedInstallCount' /t REG_DWORD /d '0' /f
    #windows build
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'LastBuild' /t REG_DWORD /d '7171' /f
    #5 for no good reason
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /v 'MaxInstallAttemptsAllowed' /t REG_DWORD /d '5' /f
    #>
    if (!$revert) {
        #removing it does not get remade on restart so we will just remove it for now 
        Reg.exe delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsAI\LastConfiguration' /f *>$null

        Reg.exe delete 'HKCU\Software\Microsoft\Windows\Shell\Copilot' /v 'CopilotLogonTelemetryTime' /f *>$null
        Reg.exe delete 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.Copilot_8wekyb3d8bbwe\Copilot.StartupTaskId' /f *>$null
        Reg.exe delete 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe\WebViewHostStartupId' /f *>$null
        Reg.exe delete 'HKCU\Software\Microsoft\Copilot' /v 'WakeApp' /f *>$null
    }
    
    #set for local machine and current user to be sure
    $hives = @('HKLM', 'HKCU')
    foreach ($hive in $hives) {
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v 'TurnOffWindowsCopilot' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableAIDataAnalysis' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'AllowRecallEnablement' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableClickToDo' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'TurnOffSavingSnapshots' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableSettingsAgent' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableAgentConnectors' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableAgentWorkspaces' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableRemoteAgentConnectors' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        #only for insiders using enterprise or education as of right now (12/23/25)
        #Reg.exe add "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v 'DisableRecallDataProviders' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat" /v 'IsUserEligible' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Microsoft\Windows\Shell\Copilot" /v 'IsCopilotAvailable' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add "$hive\SOFTWARE\Microsoft\Windows\Shell\Copilot" /v 'CopilotDisabledReason' /t REG_SZ /d @('FeatureIsDisabled', ' ')[$revert] /f *>$null
    }
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\Microsoft.Copilot_8wekyb3d8bbwe' /v 'Value' /t REG_SZ /d @('Deny', 'Prompt')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe' /v 'Value' /t REG_SZ /d @('Deny', 'Prompt')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\systemAIModels' /v 'Value' /t REG_SZ /d @('Deny', 'Prompt')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\Capabilities\systemAIModels' /v 'RecordUsageData' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps' /v 'AgentActivationEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'ShowCopilotButton' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\input\Settings' /v 'InsightsEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\Shell\ClickToDo' /v 'DisableClickToDo' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #remove copilot from search
    Write-Status -msg "$(@('Disabling', 'Enabling')[$revert]) Copilot In Windows Search..."
    Reg.exe add 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer' /v 'DisableSearchBoxSuggestions' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable copilot in edge
    Write-Status -msg "$(@('Disabling', 'Enabling')[$revert]) Copilot In Edge..."
    #keeping depreciated policies incase user has older versions of edge
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotCDPPageContext' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null #depreciated shows Unknown policy in edge://policy
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'CopilotPageContext' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'HubsSidebarEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'EdgeEntraCopilotPageContext' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'Microsoft365CopilotChatIconEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null #depreciated shows Unknown policy in edge://policy
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'EdgeHistoryAISearchEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'ComposeInlineEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'GenAILocalFoundationalModelSettings' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'BuiltInAIAPIsEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'AIGenThemesEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'DevToolsGenAiSettings' /t REG_DWORD /d @('2', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'ShareBrowsingHistoryWithCopilotSearchAllowed' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #disable edge copilot mode 
    # "enabled_labs_experiments":["edge-copilot-mode@2"]
    # view flags at edge://flags
    taskkill.exe /im msedge.exe /f *>$null
    $config = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State"
    if (Test-Path $config) {
        #powershell core bug where json that has empty strings will error
        try {
            $jsonContent = (Get-Content $config -Raw -Encoding UTF8).Replace('""', '"_empty"') | ConvertFrom-Json -ErrorAction Stop
            $fail = $false
        }
        catch {
            Write-Status -msg 'Unable to set Edge flags to disable Copilot due to a different langauge being used' -errorOutput 
            Write-Status -msg 'You can manually disable the Copilot flags at [edge://flags] in the browser' -errorOutput 
            $fail = $true
        }
        
        if (!$fail) {
            try {
                if (($jsonContent.browser | Get-Member -MemberType NoteProperty enabled_labs_experiments -ErrorAction Stop) -eq $null) {
                    $jsonContent.browser | Add-Member -MemberType NoteProperty -Name enabled_labs_experiments -Value @()
                }
                $flags = @(
                    'edge-copilot-mode@2', 
                    'edge-ntp-composer@2', #disables the copilot search in new tab page 
                    'edge-compose@2' #disables the ai writing help 
                )
                if ($revert) {
                    $jsonContent.browser.enabled_labs_experiments = @($jsonContent.browser.enabled_labs_experiments | Where-Object { $_ -notin $flags })
                }
                else {
                    foreach ($flag in $flags) {
                        if ($jsonContent.browser.enabled_labs_experiments -notcontains $flag) {
                            $jsonContent.browser.enabled_labs_experiments += $flag
                        }
                    }
                }
        
                $newContent = $jsonContent | ConvertTo-Json -Compress -Depth 100 
                #add back the empty strings 
                $newContent = $newContent.replace('"_empty"', '""')
                Set-Content $config -Value $newContent -Encoding UTF8 -Force
            }
            catch {
                Write-Status -msg 'Edge Browser has never been opened on this machine unable to set flags...' -errorOutput 
                Write-Status -msg 'Open Edge once and run this tweak again' -errorOutput 
            }
        }
        
    }
   
    #disable office ai with group policy
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\training\general' /v 'disabletraining' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\training\specific\adaptivefloatie' /v 'disabletrainingofadaptivefloatie' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable connected experiences in office should prevent copilot from working 
    Reg.exe add 'HKCU\Software\Policies\Microsoft\office\16.0\common\privacy' /v 'controllerconnectedservicesenabled' /t REG_DWORD /d @('2', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Policies\Microsoft\office\16.0\common\privacy' /v 'usercontentdisabled' /t REG_DWORD /d @('2', '1')[$revert] /f *>$null
    #disable copilot buttons in word
    #Reg.exe add 'HKCU\Software\Policies\Microsoft\office\16.0\word\disabledcmdbaritemslist' /v 'TCID1' /t REG_SZ /d '47229' /f
    #Reg.exe add 'HKCU\Software\Policies\Microsoft\office\16.0\word\disabledcmdbaritemslist' /v 'TCID2' /t REG_SZ /d '43223' /f
    #Reg.exe add 'HKCU\Software\Policies\Microsoft\office\16.0\word\disabledcmdbaritemslist' /v 'TCID3' /t REG_SZ /d '34872' /f
    #Reg.exe add 'HKCU\Software\Policies\Microsoft\office\16.0\word\disabledcmdbaritemslist' /v 'TCID4' /t REG_SZ /d '42552' /f
    #disable copilot in word
    Reg.exe add 'HKCU\Software\Microsoft\Office\16.0\Word\Options' /v 'EnableCopilot' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #disable copilot in excel
    Reg.exe add 'HKCU\Software\Microsoft\Office\16.0\Excel\Options' /v 'EnableCopilot' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #disable copilot in onenote
    Reg.exe add 'HKCU\Software\Microsoft\Office\16.0\OneNote\Options\Copilot' /v 'CopilotEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Office\16.0\OneNote\Options\Copilot' /v 'CopilotNotebooksEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Office\16.0\OneNote\Options\Copilot' /v 'CopilotSkittleEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #disable office ai content safety
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\general' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\alternativetext' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\imagequestionandanswering' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\promptassistance' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\rewrite' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\summarization' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\summarizationwithreferences' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\contentsafety\specific\texttotable' /v 'disablecontentsafety' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable additional keys
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings' /v 'AutoOpenCopilotLargeScreens' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\generativeAI' /v 'Value' /t REG_SZ /d @('Deny', 'Allow')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\systemAIModels' /v 'Value' /t REG_SZ /d @('Deny', 'Allow')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' /v 'LetAppsAccessGenerativeAI' /t REG_DWORD /d @('2', '1')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' /v 'LetAppsAccessSystemAIModels' /t REG_DWORD /d @('2', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsCopilot' /v 'AllowCopilotRuntime' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins' /v 'CopilotPWAPin' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins' /v 'RecallPin' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #disable copilot background app access 
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Copilot_8wekyb3d8bbwe' /v 'DisabledByUser' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Copilot_8wekyb3d8bbwe' /v 'Disabled' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Copilot_8wekyb3d8bbwe' /v 'SleepDisabled' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe' /v 'DisabledByUser' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe' /v 'Disabled' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe' /v 'SleepDisabled' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable for all users
    $sids = (Get-ChildItem 'registry::HKEY_USERS').Name | Where-Object { $_ -like 'HKEY_USERS\S-1-5-21*' -and $_ -notlike '*Classes*' } 
    foreach ($sid in $sids) {
        Reg.exe add "$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins" /v 'CopilotPWAPin' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add "$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins" /v 'RecallPin' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    }
    #disable ai actions
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1853569164' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\4098520719' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\929719951' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #enable new feature to hide ai actions in context menu when none are avaliable 
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1646260367' /v 'EnabledState' /t REG_DWORD /d @('2', '0')[$revert] /f *>$null
    #disable additional ai velocity ids found from: https://github.com/phantomofearth/windows-velocity-feature-lists
    #keep in mind these may or may not do anything depending on the windows build 
    #disable copilot nudges
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\1546588812' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\203105932' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\2381287564' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3189581453' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3552646797' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable copilot in taskbar and systray
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3389499533' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\4027803789' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\450471565' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #enable removing ai componets (not sure what this does yet)
    #Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\2931206798' /v 'EnabledState' /t REG_DWORD /d '2' /f
    #Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3098978958' /v 'EnabledState' /t REG_DWORD /d '2' /f
    #Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3233196686' /v 'EnabledState' /t REG_DWORD /d '2' /f
    #disable core ai / click to do with feature management 
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\2283032206' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\502943886' /v 'EnabledState' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable ask copilot (taskbar search)
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'TaskbarCompanion' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\Shell\BrandedKey' /v 'BrandedKeyChoiceType' /t REG_SZ /d @('Search', 'App')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\Shell\BrandedKey' /v 'AppAumid' /t REG_SZ /d @(' ', 'Microsoft.Copilot_8wekyb3d8bbwe!App')[$revert] /f *>$null
    Reg.exe add 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CopilotKey' /v 'SetCopilotHardwareKey' /t REG_SZ /d @(' ', 'Microsoft.Copilot_8wekyb3d8bbwe!App')[$revert] /f *>$null
    #disable recall customized homepage 
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\WindowsSettingHandlers' /v 'A9HomeContentEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #disable typing data harvesting for ai training 
    Reg.exe add 'HKCU\Software\Microsoft\InputPersonalization' /v 'RestrictImplicitInkCollection' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\InputPersonalization' /v 'RestrictImplicitTextCollection' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore' /v 'HarvestContacts' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\CPSS\Store\InkingAndTypingPersonalization' /v 'Value' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
    #hide copilot ads in settings home page 
    Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent' /v 'DisableConsumerAccountStateContent' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    #disable office hub startup
    Reg.exe add 'HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe\WebViewHostStartupId' /v 'State' /t REG_DWORD /d @('1', '2')[$revert] /f *>$null
    #disable ai image creator in paint
    Write-Status -msg "$(@('Disabling', 'Enabling')[$revert]) Image Creator In Paint..."
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableImageCreator' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableCocreator' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableGenerativeFill' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableGenerativeErase' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Paint' /v 'DisableRemoveBackground' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
    # disable experimental agentic features
    # Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\IsoEnvBroker" /v "Enabled" /t REG_DWORD /d "0" /f
    # Reg.exe add "HKLM\SYSTEM\ControlSet001\Services\IsoEnvBroker" /v "Enabled" /t REG_DWORD /d "0" /f
    # leaving commented since its still only in preview builds

    #apply reg keys for default user to disable for any new users created
    #unload just incase
    [GC]::Collect()
    reg.exe unload 'HKU\DefaultUser' *>$null
    try {
        reg.exe load 'HKU\DefaultUser' "$env:SystemDrive\Users\Default\NTUSER.DAT" >$null
        #reg.exe tidak melempar exception, jadi cek kode keluarnya
        $hiveloaded = ($LASTEXITCODE -eq 0)
        if (-not $hiveloaded) { Write-Status -msg 'Unable to Load Default User Hive...' -errorOutput }
    }
    catch {
        Write-Status -msg 'Unable to Load Default User Hive...' -errorOutput 
        $hiveloaded = $false
    }

    if ($hiveloaded) {
        Write-Status -msg "$(@('Disabling', 'Enabling')[$revert]) AI for new users..." 
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' /v 'TurnOffWindowsCopilot' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'DisableAIDataAnalysis' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'AllowRecallEnablement' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'DisableClickToDo' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'TurnOffSavingSnapshots' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'DisableSettingsAgent' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'DisableAgentConnectors' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'DisableAgentWorkspaces' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' /v 'DisableRemoteAgentConnectors' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Microsoft\Windows\Shell\Copilot\BingChat' /v 'IsUserEligible' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Microsoft\Windows\Shell\Copilot' /v 'IsCopilotAvailable' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Microsoft\Windows\Shell\Copilot' /v 'CopilotDisabledReason' /t REG_SZ /d @('FeatureIsDisabled', ' ')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\Microsoft.Copilot_8wekyb3d8bbwe' /v 'Value' /t REG_SZ /d @('Deny', 'Prompt')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps' /v 'AgentActivationEnabled' /t REG_DWORD /d @('0', '1')[$revert]  /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'ShowCopilotButton' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\input\Settings' /v 'InsightsEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\Shell\ClickToDo' /v 'DisableClickToDo' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\Explorer' /v 'DisableSearchBoxSuggestions' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsCopilot' /v 'AllowCopilotRuntime' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins' /v 'CopilotPWAPin' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins' /v 'RecallPin' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'TaskbarCompanion' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\Shell\BrandedKey' /v 'BrandedKeyChoiceType' /t REG_SZ /d @('Search', 'App')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\Shell\BrandedKey' /v 'AppAumid' /t REG_SZ /d @(' ', 'Microsoft.Copilot_8wekyb3d8bbwe!App')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\SOFTWARE\Policies\Microsoft\Windows\CopilotKey' /v 'SetCopilotHardwareKey' /t REG_SZ /d @(' ', 'Microsoft.Copilot_8wekyb3d8bbwe!App')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\SettingSync\WindowsSettingHandlers' /v 'A9HomeContentEnabled' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\InputPersonalization' /v 'RestrictImplicitInkCollection' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\InputPersonalization' /v 'RestrictImplicitTextCollection' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\InputPersonalization\TrainedDataStore' /v 'HarvestContacts' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        Reg.exe add 'HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\CPSS\Store\InkingAndTypingPersonalization' /v 'Value' /t REG_DWORD /d @('0', '1')[$revert] /f *>$null
        if ($revert) {
            Reg.exe delete 'HKU\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' /v '{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}' /f *>$null
        }
        else {
            Reg.exe add 'HKU\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' /v '{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}' /t REG_SZ /d 'Ask Copilot' /f *>$null
        }

        reg.exe unload 'HKU\DefaultUser' *>$null
    }

    #disable ask copilot in context menu
    if ($revert) {
        Reg.exe delete 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' /v '{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}' /f *>$null
    }
    else {
        Reg.exe add 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked' /v '{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}' /t REG_SZ /d 'Ask Copilot' /f *>$null
    }
    #Reg.exe add 'HKLM\SYSTEM\CurrentControlSet\Services\WSAIFabricSvc' /v 'Start' /t REG_DWORD /d @('4', '2')[$revert] /f *>$null
    try {
        Stop-Service -Name WSAIFabricSvc -Force -ErrorAction Stop
    }
    catch {
        #ignore error when svc is already removed
    }
    
    $backupPath = "$env:USERPROFILE\RemoveWindowsAI\Backup"
    $backupFileWSAI = 'WSAIFabricSvc.reg'
    $backupFileAAR = 'AARSVC.reg'
    if ($revert) {
        if (Test-Path "$backupPath\$backupFileWSAI") {
            Reg.exe import "$backupPath\$backupFileWSAI" *>$null
            sc.exe create WSAIFabricSvc binPath= "$env:windir\System32\svchost.exe -k WSAIFabricSvcGroup -p" *>$null
        }
        else {
            Write-Status -msg "Path Not Found: $backupPath\$backupFileWSAI" -errorOutput 
        }
        
    }
    else {
        if ($backup) {
            Write-Status -msg 'Backing up WSAIFabricSvc...'
            #export the service to a reg file before removing it 
            if (!(Test-Path $backupPath)) {
                New-Item $backupPath -Force -ItemType Directory | Out-Null
            }
            #this will hang if the service has already been exported
            # if (!(Test-Path "$backupPath\$backupFileWSAI")) {
            Reg.exe export 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSAIFabricSvc' "$backupPath\$backupFileWSAI" /y | Out-Null #add overwrite file /y switch
            # }
        }
        Write-Status -msg 'Removing WSAIFabricSvc...'
        #delete the service
        sc.exe delete WSAIFabricSvc *>$null
    }
    if (!$revert) {
        #remove conversational agent service (used to be used for cortana, prob going to be updated for new ai agents and copilot)
        try {
            $aarSVCName = (Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.name -like '*aarsvc*' }).Name
        }
        catch {
            #aarsvc already removed
        }
        

        if ($aarSVCName) {
            if ($backup) {
                Write-Status -msg 'Backing up Agent Activation Runtime Service...'
                #export the service to a reg file before removing it 
                if (!(Test-Path $backupPath)) {
                    New-Item $backupPath -Force -ItemType Directory | Out-Null
                }
                #this will hang if the service has already been exported
                # if (!(Test-Path "$backupPath\$backupFileAAR")) {
                Reg.exe export 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AarSvc' "$backupPath\$backupFileAAR" /y | Out-Null
                # }
            }
            Write-Status -msg 'Removing Agent Activation Runtime Service...'
            #delete the service
            try {
                Stop-Service -Name $aarSVCName -Force -ErrorAction Stop
            }
            catch {
                try {
                    Stop-Service -Name AarSvc -Force -ErrorAction Stop
                }
                catch {
                    #neither are running
                }
                
            }
            
            sc.exe delete AarSvc *>$null
        }
    }
    else {
        Write-Status 'Restoring Agent Activation Runtime Service...'

        if (Test-Path "$backupPath\$backupFileAAR") {
            Reg.exe import "$backupPath\$backupFileAAR" *>$null
            sc.exe create AarSvc binPath= "$env:windir\system32\svchost.exe -k AarSvcGroup -p" *>$null
        }
        else {
            Write-Status -msg "Path Not Found: $backupPath\$backupFileAAR" -errorOutput 
        }
    }
  


    #block copilot from communicating with server
    if ($revert) {
        if ((Test-Path "$backupPath\HKCR_Copilot.reg") -or (Test-Path "$backupPath\HKCU_Copilot.reg")) {
            Reg.exe import "$backupPath\HKCR_Copilot.reg" *>$null
            Reg.exe import "$backupPath\HKCU_Copilot.reg" *>$null
        }
        else {
            Write-Status -msg "Unable to Find HKCR_Copilot.reg or HKCU_Copilot.reg in [$backupPath]" -errorOutput 
        }
    }
    else {
        if ($backup) {
            #backup .copilot file extension
            Reg.exe export 'HKEY_CLASSES_ROOT\.copilot' "$backupPath\HKCR_Copilot.reg" /y *>$null
            Reg.exe export 'HKEY_CURRENT_USER\Software\Classes\.copilot' "$backupPath\HKCU_Copilot.reg" /y *>$null
        }
        Write-Status -msg 'Removing .copilot File Extension...' 
        Reg.exe delete 'HKCU\Software\Classes\.copilot' /f *>$null
        Reg.exe delete 'HKCR\.copilot' /f *>$null
    }

    #disabling and removing voice access, recently added ai powered
    Reg.exe add 'HKCU\Software\Microsoft\VoiceAccess' /v 'RunningState' /t REG_DWORD /d @('0', '1')[$revert] /f >$null
    Reg.exe add 'HKCU\Software\Microsoft\VoiceAccess' /v 'TextCorrection' /t REG_DWORD /d @('1', '2')[$revert] /f >$null
    Reg.exe add 'HKCU\Software\Microsoft\Windows NT\CurrentVersion\AccessibilityTemp' /v @('0', '1')[$revert] /t REG_DWORD /d '0' /f >$null
    $startMenu = "$env:appdata\Microsoft\Windows\Start Menu\Programs\Accessibility"
    $voiceExe = "$env:windir\System32\voiceaccess.exe"
    if ($backup) {
        Write-Status -msg 'Backing up Voice Access...'
        if (!(Test-Path $backupPath)) {
            New-Item $backupPath -Force -ItemType Directory | Out-Null
        }
        Copy-Item $voiceExe -Destination $backupPath -Force -ErrorAction SilentlyContinue | Out-Null
        Copy-Item "$startMenu\VoiceAccess.lnk" -Destination $backupPath -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    if ($revert) {
        if ((Test-Path "$backupPath\VoiceAccess.exe") -and (Test-Path "$backupPath\VoiceAccess.lnk")) {
            Write-Status -msg 'Restoring Voice Access...'
            Move-Item "$backupPath\VoiceAccess.exe" -Destination "$env:windir\System32" -Force | Out-Null
            Move-Item "$backupPath\VoiceAccess.lnk" -Destination $startMenu -Force | Out-Null
        }
        else {
            Write-Status -msg 'Voice Access Backup NOT Found!' -errorOutput 
        }
    }
    else {
        Write-Status -msg 'Removing Voice Access...'
        $command = "Remove-item -path $env:windir\System32\voiceaccess.exe -force"
        Run-Trusted -command $command -psversion $psversion
        Start-Sleep 1
        Remove-Item "$startMenu\VoiceAccess.lnk" -Force -ErrorAction SilentlyContinue
    }

    
    $root = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture'
    $allFX = (Get-ChildItem $root -Recurse).Name | Where-Object { $_ -like '*FxProperties' }
    #search the fx props for VocalEffectPack and add {1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5 = 1
    foreach ($fxPath in $allFX) {
        $keys = Get-ItemProperty "registry::$fxPath"
        foreach ($key in $keys) {
            if ($key | Get-Member -MemberType NoteProperty | Where-Object { $_.Name -like '{*},*' } | Where-Object { $_.Definition -like '*#VocaEffectPack*' }) {
                Write-Status -msg "$(@('Disabling','Enabling')[$revert]) AI Voice Effects..."
                $regPath = Convert-Path $key.PSPath
                if ($revert) {
                    #enable
                    $command = "Reg.exe delete '$regPath' /v '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5' /f"
                    Run-Trusted -command $command -psversion $psversion
                }
                else {
                    #disable
                    $command = "Reg.exe add '$regPath' /v '{1da5d803-d492-4edd-8c23-e0c0ffee7f0e},5' /t REG_DWORD /d '1' /f"
                    Run-Trusted -command $command -psversion $psversion
                }
                
            }
        }
    }

    #disable gaming copilot 
    #found from: https://github.com/meetrevision/playbook/issues/197
    #not sure this really does anything in my testing gaming copilot still appears 
    if ($revert) {
        $command = "reg delete 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.Xbox.GamingAI.Companion.Host.GamingCompanionHostOptions' /f"
        Run-Trusted -command $command -psversion $psversion
    }
    else {
        $command = "reg add 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.Xbox.GamingAI.Companion.Host.GamingCompanionHostOptions' /v 'ActivationType' /t REG_DWORD /d 0 /f;
    reg add 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.Xbox.GamingAI.Companion.Host.GamingCompanionHostOptions' /v 'Server' /t REG_SZ /d `" `" /f
    "
        Run-Trusted -command $command -psversion $psversion
    }
    

    #remove windows ai dll contracts 
    $command = "
    Reg delete 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\WellKnownContracts' /v 'Windows.AI.Actions.ActionsContract' /f
    Reg delete 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\WellKnownContracts' /v 'Windows.AI.Agents.AgentsContract' /f
    Reg delete 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\WellKnownContracts' /v 'Windows.AI.MachineLearning.MachineLearningContract' /f 
    Reg delete 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\WellKnownContracts' /v 'Windows.AI.MachineLearning.Preview.MachineLearningPreviewContract' /f
    "
    Run-Trusted -command $command -psversion $psversion

    #disable ai setting in uwp photos app
    $uwpPhotosSettings = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.Photos_8wekyb3d8bbwe\Settings\settings.dat"
    if (Test-Path $uwpPhotosSettings) {
        [GC]::Collect()
        reg.exe unload 'HKU\TEMP' *>$null
        taskkill /im photos.exe /f *>$null
        reg.exe load HKU\TEMP $uwpPhotosSettings >$null
        if (!$revert) {
            $regContent = @'
Windows Registry Editor Version 5.00

[HKEY_USERS\TEMP\LocalState] 
"ImageCategorizationConsentDismissed"=hex(5f5e10c):74,00,72,00,75,00,65,00,00,\
  00,4c,a0,89,0c,f7,2e,dc,01
"ImageCategorizationConsent"=hex(5f5e10c):66,00,61,00,6c,00,73,00,65,00,00,00,\
  6c,c4,53,ae,c5,51,dc,01
'@
        }
        else {
            $regContent = @'
Windows Registry Editor Version 5.00

[HKEY_USERS\TEMP\LocalState]
"ImageCategorizationConsentDismissed"=hex(5f5e10c):74,00,72,00,75,00,65,00,00,\
  00,4c,a0,89,0c,f7,2e,dc,01
"ImageCategorizationConsent"=hex(5f5e10c):74,00,72,00,75,00,65,00,00,00,79,e7,\
  fe,c5,c4,51,dc,01
'@
        }
       
        
        New-Item "$($tempDir)DisableAIPhotos.reg" -Value $regContent -Force | Out-Null
        regedit.exe /s "$($tempDir)DisableAIPhotos.reg"
        Start-Sleep 1
        reg unload HKU\TEMP >$null
        Remove-Item "$($tempDir)DisableAIPhotos.reg" -Force -ErrorAction SilentlyContinue
    }

    #disable app actions
    #method credit : https://github.com/agadiffe/WindowsMize
    $settingsDat = "$env:LOCALAPPDATA\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\Settings\settings.dat"

    if (Test-Path $settingsDat) {
        Write-Status -msg "$(@('Disabling','Enabling')[$revert]) App Actions..."

        $apps = @(
            'Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe' 
            'Microsoft.Office.ActionsServer_8wekyb3d8bbwe' 
            'MSTeams_8wekyb3d8bbwe' 
            'Microsoft.Paint_8wekyb3d8bbwe' 
            'Microsoft.Windows.Photos_8wekyb3d8bbwe'
            'MicrosoftWindows.Client.CBS_cw5n1h2txyewy' #describe image (system)
        )
        #prevent file lock
        Stop-Process -Name @('SearchHost', 'AppActions') -Force -ErrorAction SilentlyContinue
        foreach ($app in $apps) {
            $setting = [PSCustomObject]@{
                Name  = $app
                Path  = 'LocalState\DisabledApps'
                Value = @('1', '0')[$revert] # 1 = disable    0 = enable
                Type  = '5f5e10b'
            }
            
            $setting | Set-UwpAppRegistryEntry -FilePath $settingsDat
        }
     
    }
    

    #force policy changes
    Write-Status -msg 'Applying Registry Changes...'
    gpupdate /force /wait:0 >$null

}
