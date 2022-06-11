BeforeAll {
    Import-Module ./.sdv/Sdv.psm1 -Force

    Enter-LoggingGroup ("Starting application {0}" -f $Component.Name)
    Find-SdvVehicleApp | Get-SdvComponent | Start-SdvComponent
    Exit-LoggingGroup

    Write-SdvLogging "Waiting 10 seconds"
    Start-Sleep 10

    Enter-LoggingGroup ("Stopping application {0}" -f $Component.Name)
    Find-SdvVehicleApp | Get-SdvComponent | Stop-SdvComponent | Tee-Object -Variable 'Output'
    Exit-LoggingGroup
    $AppOutput = $Output | Where-Object { $_ -match "== APP ==" }    
}

Describe "Main Loop" {

    Context "SeatAdjuster" {
        It 'should have requested a new seat position' {
            $AppOutput = '== APP == Request setting seat position to  1'
            $AppOutput | should -contain '== APP == Request setting seat position to  1'
        }
        
        It 'should receive the new seat position subscription' {
            $AppOutput = '== APP == Subscriber received: id=1, SeatPosition="1", content_type="application/json"'
            $AppOutput | should -contain '== APP == Subscriber received: id=1, SeatPosition="1", content_type="application/json"'
        }
    }    

    Context "vehicleapi" {
        It 'should have processed the new seat position' {
            $AppOutput = '== APP == New position is  base: 1'
            $AppOutput | should -contain '== APP == New position is  base: 1'
        }
    }
}