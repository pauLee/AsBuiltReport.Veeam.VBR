function Invoke-AsBuiltReport.Veeam.VBR {
    <#
    .SYNOPSIS
        PowerShell script to document the configuration of Veeam VBR in Word/HTML/Text formats
    .DESCRIPTION
        Documents the configuration of Veeam VBR in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.6.0
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VBR
    #>

	# Do not remove or add to these parameters
    param (
        [String[]] $Target,
        [PSCredential] $Credential
    )

    Write-PScriboMessage -IsWarning "Please refer to the AsBuiltReport.Veeam.VBR github website for more detailed information about this project."
    Write-PScriboMessage -IsWarning "Do not forget to update your report configuration file after each new version release."
    Write-PScriboMessage -IsWarning "Documentation: https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VBR"
    Write-PScriboMessage -IsWarning "Issues or bug reporting: https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VBR/issues"

    Try {
        $InstalledVersion = (Get-Module -ListAvailable -Name AsBuiltReport.Veeam.VBR -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version)[0]

        if ($InstalledVersion) {
            Write-PScriboMessage -IsWarning "Installed AsBuiltReport.Veeam.VBR Version: $($InstalledVersion.ToString())"
            $MostCurrentVersion = Find-Module -Name AsBuiltReport.Veeam.VBR -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
            if ($MostCurrentVersion -and ($MostCurrentVersion -gt $InstalledVersion)) {
                Write-PScriboMessage -IsWarning "New Update: AsBuiltReport.Veeam.VBR Version: $($MostCurrentVersion.ToString())"
                Write-PScriboMessage -IsWarning "To Update run: Update-Module -Name AsBuiltReport.Veeam.VBR -Force"
            }
        }
    } Catch {
        Write-PscriboMessage -IsWarning $_.Exception.Message
    }

    # Import Report Configuration
    $Report = $ReportConfig.Report
    $InfoLevel = $ReportConfig.InfoLevel
    $Options = $ReportConfig.Options

    # Used to set values to TitleCase where required
    $TextInfo = (Get-Culture).TextInfo

    #region foreach loop
    foreach ($System in $Target) {
        Get-AbrVbrRequiredModule -Name 'Veeam.Backup.PowerShell' -Version '1.0'
        Get-AbrVbrServerConnection
        $VeeamBackupServer = ((Get-VBRServerSession).Server).ToString().ToUpper().Split(".")[0]
        Section -Style Heading1 $($VeeamBackupServer) {
            Paragraph "The following section provides an overview of the implemented components of Veeam Backup & Replication."
            BlankLine

            #---------------------------------------------------------------------------------------------#
            #                            Executive Summary Section                                    #
            #---------------------------------------------------------------------------------------------#
            Section -Style Heading2 'Executive Summary' {
                Get-AbrVbrInfrastructureSummary
                Get-AbrVbrTapeInfraSummary
                Get-AbrVbrInventorySummary
                Get-AbrVbrStorageInfraSummary
                # Get-AbrVbrReplInfraSummary
            }
            #---------------------------------------------------------------------------------------------#
            #                            Backup Infrastructure Section                                    #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Infrastructure.PSObject.Properties.Value -ne 0) {
                Section -Style Heading2 'Backup Infrastructure Components' {
                    Paragraph "The following section details configuration information about the Backup Server: $($VeeamBackupServer)"
                    BlankLine
                    Get-AbrVbrBackupServerInfo
                    Get-AbrVbrEnterpriseManagerInfo
                    Write-PScriboMessage "Infrastructure Licenses InfoLevel set at $($InfoLevel.Infrastructure.Licenses)."
                    if ($InfoLevel.Infrastructure.Licenses -ge 1) {
                        Get-AbrVbrInstalledLicense
                    }
                    Write-PScriboMessage "Infrastructure Settings InfoLevel set at $($InfoLevel.Infrastructure.Settings)."
                    if ($InfoLevel.Infrastructure.Settings -ge 1) {
                        Section -Style Heading3 'General Options' {
                            Paragraph "The following section details Veaam Backup & Replication general setting. General settings are applied to all jobs, backup infrastructure components and other objects managed by the backup server."
                            BlankLine
                            Get-AbrVbrConfigurationBackupSetting
                            Get-AbrVbrEmailNotificationSetting
                            Get-AbrVbrIOControlSetting
                            Get-AbrVbrBackupServerCertificate
                            Get-AbrVbrNetworkTrafficRule
                        }
                    }
                    Get-AbrVbrUserRoleAssignment
                    Get-AbrVbrCredential
                    Get-AbrVbrLocation
                    Get-AbrVbrManagedServer
                    Write-PScriboMessage "Infrastructure Backup Proxy InfoLevel set at $($InfoLevel.Infrastructure.Proxy)."
                    if ($InfoLevel.Infrastructure.Proxy -ge 1) {
                        Get-AbrVbrBackupProxy
                    }
                    Write-PScriboMessage "Infrastructure WAN Accelerator InfoLevel set at $($InfoLevel.Infrastructure.WANAccel)."
                    if ($InfoLevel.Infrastructure.WANAccel -ge 1) {
                        Get-AbrVbrWANAccelerator
                    }
                    Write-PScriboMessage "Infrastructure Service Provider InfoLevel set at $($InfoLevel.Infrastructure.ServiceProvider)."
                    if ($InfoLevel.Infrastructure.ServiceProvider -ge 1) {
                        Get-AbrVbrServiceProvider
                    }
                    Write-PScriboMessage "Infrastructure Backup Repository InfoLevel set at $($InfoLevel.Infrastructure.BR)."
                    if ($InfoLevel.Infrastructure.BR -ge 1) {
                        Get-AbrVbrBackupRepository
                        Get-AbrVbrObjectRepository
                    }
                    Write-PScriboMessage "Infrastructure ScaleOut Backup Repository InfoLevel set at $($InfoLevel.Infrastructure.SOBR)."
                    if ($InfoLevel.Infrastructure.SOBR -ge 1) {
                        Get-AbrVbrScaleOutRepository
                    }
                    Write-PScriboMessage "Infrastructure SureBackup InfoLevel set at $($InfoLevel.Infrastructure.SureBackup)."
                    if ($InfoLevel.Infrastructure.SureBackup -ge 1) {
                        Get-AbrVbrSureBackup
                    }
                }
            }
            #---------------------------------------------------------------------------------------------#
            #                            Tape Infrastructure Section                                      #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Tape.PSObject.Properties.Value -ne 0) {
                if ((Get-VBRTapeServer).count -gt 0) {
                    Section -Style Heading2 'Tape Infrastructure Components' {
                        Paragraph "The following section details Tape Infrastructure configuration information"
                        BlankLine
                        Write-PScriboMessage "Tape Server InfoLevel set at $($InfoLevel.Tape.Server)."
                        if ($InfoLevel.Tape.Server -ge 1) {
                            Get-AbrVbrTapeServer
                            if ($InfoLevel.Tape.Library -ge 1) {
                                Get-AbrVbrTapeLibrary
                            }
                            if ($InfoLevel.Tape.MediaPool -ge 1) {
                                Get-AbrVbrTapeMediaPool
                            }
                            if ($InfoLevel.Tape.Vault -ge 1) {
                                Get-AbrVbrTapeVault
                            }
                            if ($InfoLevel.Tape.NDMP -ge 1) {
                                Get-AbrVbrNDMPInfo
                            }
                        }
                    }
                }
            }
            #---------------------------------------------------------------------------------------------#
            #                                  Inventory Section                                          #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Inventory.PSObject.Properties.Value -ne 0) {
                if ((Get-VBRServer).count -gt 0) {
                    Section -Style Heading2 'Inventory Components' {
                        Paragraph "The following section provides inventory information about the Virtual Infrastructure managed by Veeam Server $(((Get-VBRServerSession).Server))."
                        BlankLine
                        Write-PScriboMessage "Virtual Inventory InfoLevel set at $($InfoLevel.Inventory.VI)."
                        if ($InfoLevel.Inventory.VI -ge 1) {
                            Get-AbrVbrVirtualInfrastructure
                        }
                        Write-PScriboMessage "Physical Inventory InfoLevel set at $($InfoLevel.Inventory.PHY)."
                        if ($InfoLevel.Inventory.PHY -ge 1) {
                            Get-AbrVbrPhysicalInfrastructure

                        }
                        Write-PScriboMessage "File Shares Inventory InfoLevel set at $($InfoLevel.Inventory.FileShare)."
                        if ($InfoLevel.Inventory.FileShare -ge 1) {
                            Get-AbrVbrFileSharesInfo

                        }
                    }
                }
            }
            #---------------------------------------------------------------------------------------------#
            #                                  Storage Infrastructure Section                             #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Storage.PSObject.Properties.Value -ne 0) {
                if ((Get-NetAppHost).count -gt 0) {
                    Section -Style Heading2 'Storage Infrastructure Components' {
                        Paragraph "The following section provides information about the storage infrastructure managed by Veeam Server $(((Get-VBRServerSession).Server))."
                        BlankLine
                        Write-PScriboMessage "NetApp Ontap InfoLevel set at $($InfoLevel.Storage.Ontap)."
                        if ($InfoLevel.Storage.Ontap -ge 1) {
                            Get-AbrVbrStorageOntap
                        }
                        Write-PScriboMessage "Dell Isilon InfoLevel set at $($InfoLevel.Storage.Isilon)."
                        if ($InfoLevel.Storage.Isilon -ge 1) {
                            Get-AbrVbrStorageIsilon
                        }
                    }
                }
            }
            #---------------------------------------------------------------------------------------------#
            #                                   Replication Section                                       #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Replication.PSObject.Properties.Value -ne 0) {
                if ((Get-VBRReplica).count -gt 0 -or ((Get-VBRFailoverPlan).count -gt 0))  {
                    Section -Style Heading2 'Replication Components' {
                        Paragraph "The following section provides information about the replications managed by Veeam Server $(((Get-VBRServerSession).Server))."
                        BlankLine
                        Write-PScriboMessage "Replica InfoLevel set at $($InfoLevel.Replication.Replica)."
                        if ($InfoLevel.Replication.Replica -ge 1) {
                            Get-AbrVbrReplReplica
                        }
                        Write-PScriboMessage "Failover Plan InfoLevel set at $($InfoLevel.Replication.FailoverPlan)."
                        if ($InfoLevel.Replication.FailoverPlan -ge 1) {
                            Get-AbrVbrReplFailoverPlan
                        }
                    }
                }
            }
            #---------------------------------------------------------------------------------------------#
            #                                  Backup Jobs Section                                        #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Jobs.PSObject.Properties.Value -ne 0) {
                if (((Get-VBRJob -WarningAction SilentlyContinue).count -gt 0) -or ((Get-VBRTapeJob).count -gt 0) -or ((Get-VBRSureBackupJob).count -gt 0)) {
                    Section -Style Heading2 'Jobs Summary' {
                        Paragraph "The following section provides information about the configured jobs in Veeam Server: $(((Get-VBRServerSession).Server))."
                        BlankLine
                        Write-PScriboMessage "Backup Jobs InfoLevel set at $($InfoLevel.Jobs.Backup)."
                        if ($InfoLevel.Jobs.Backup -ge 1) {
                            Get-AbrVbrBackupjob
                            Get-AbrVbrBackupjobVMware
                            Get-AbrVbrBackupjobHyperV
                        }
                        Write-PScriboMessage "Replication Jobs InfoLevel set at $($InfoLevel.Jobs.Replication)."
                        if ($InfoLevel.Jobs.Replication -ge 1) {
                            Get-AbrVbrRepljob
                            Get-AbrVbrRepljobVMware
                            Get-AbrVbrRepljobHyperV
                        }
                        Write-PScriboMessage "Tape Jobs InfoLevel set at $($InfoLevel.Jobs.Tape)."
                        if ($InfoLevel.Jobs.Tape -ge 1) {
                            Get-AbrVbrTapejob
                            Get-AbrVbrBackupToTape
                            Get-AbrVbrFileToTape
                        }
                        Write-PScriboMessage "SureBackup Jobs InfoLevel set at $($InfoLevel.Jobs.SureBackup)."
                        if ($InfoLevel.Jobs.SureBackup -ge 1) {
                            Get-AbrVbrSureBackupjob
                            Get-AbrVbrSureBackupjobVMware
                        }
                        Write-PScriboMessage "Agent Jobs InfoLevel set at $($InfoLevel.Jobs.Agent)."
                        if ($InfoLevel.Jobs.Agent -ge 1) {
                            Get-AbrVbrAgentBackupjob
                            Get-AbrVbrAgentBackupjobConf
                        }
                        Write-PScriboMessage "File Share Jobs InfoLevel set at $($InfoLevel.Jobs.FileShare)."
                        if ($InfoLevel.Jobs.FileShare -ge 1) {
                            Get-AbrVbrFileShareBackupjob
                            Get-AbrVbrFileShareBackupjobConf
                        }
                    }
                }
            }
            #---------------------------------------------------------------------------------------------#
            #                      Infrastructure Security Hardening Section                              #
            #---------------------------------------------------------------------------------------------#
            if ($InfoLevel.Security.PSObject.Properties.Value -ne 0) {
                Section -Style Heading2 'Infrastructure Security Hardening' {
                    Paragraph 'Protecting your infrastructure successfully is all about understanding the current attack vectors; what and whom you are protecting, your Veeam infrastructure, against. If you know what and whom you are protecting against, makes it easier to take the correct countermeasures. One of those countermeasures is hardening.'
                    BlankLine
                    Paragraph 'Looking at the different Veeam Backup & Replication components you have to protect the following components:'
                    BlankLine
                    Paragraph '* Veeam Backup server'
                    Paragraph '* User Accounts'
                    Paragraph '* Backup repositories'
                    Paragraph '* Backup data flows'

                    if ($InfoLevel.Security.Infrastructure -ge 1) {
                        Get-AbrVbrSecInfraHard
                    }
                }
            }
        }
        #Disconnect-VBRServer
	}
	#endregion foreach loop
}
