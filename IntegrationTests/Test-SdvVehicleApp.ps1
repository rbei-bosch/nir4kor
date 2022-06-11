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

$Configuration = New-PesterConfiguration
$Configuration.Run.Path = "./IntegrationTests/"
$Configuration.Run.TestExtension = ".tst.ps1"
$Configuration.TestResult.Enabled = $true
$Configuration.TestResult.OutputFormat = "JUnitXml"
$Configuration.TestResult.OutputPath = ".sdv/tmp/IntegrationTest/junit.xml"
$Configuration.Output.Verbosity = "Detailed"

Invoke-Pester -Configuration $Configuration
