Write-Host "===> Preparing configuration" -ForegroundColor Yellow

$location = (Get-Location).Path

Get-Content $location\configuration.env | Where-Object { $_.length -gt 0 } | Where-Object { !$_.StartsWith("#") } | ForEach-Object {
    $var = $_.Split('=', 2).Trim()
    New-Variable -Scope Script -Name $var[0] -Value $var[1]
}
## clone git repository
$Template = Get-Variable Template -valueOnly
## clone git repository
$GitRepository = Get-Variable Reprository -valueOnly
## clone git repository
$SimulationTest = Get-Variable SimulationTest -valueOnly
## clone git repository
$LogbackFile = Get-Variable LogbackFile -valueOnly


if ($Template -eq "local") {
    Write-Host "===> Bring Up Services on local machine" -ForegroundColor Yellow
    Copy-Item -Path $location\templates\$Template.yaml.template -Destination $location\docker-compose.yml -PassThru
}
else {
    Write-Host "===> Bring Up Repository Services Up" -ForegroundColor Yellow
    ## clone git repository
    New-Item -Path $location -Name "gatling" -ItemType "directory"
    Start-Sleep -s 5
    Set-Location $location\gatling
    git clone $GitRepository
    Start-Sleep -s 10
    $projectDirectory = Get-ChildItem -Directory 
    $filePath = $location + "\templates\" + $Template + ".yaml.template"
    $filePathCopy = $location + "\templates\" + $Template + ".yaml.template.txt"
    #Configure Docker parameters
    $gatlingResources = "gatling\" + $projectDirectory + "\src\test\resources"
    $gatlingTest = "gatling." + $SimulationTest
    $gatlingResults = "gatling\" + $projectDirectory + "\target"
    $gatlingSimulations = "gatling\" + $projectDirectory + "\src\test\scala\gatling"
    $gatlingLogs = "gatling\" + $projectDirectory + "\log";
    $gatlingLogback = "logback\" + $LogbackFile;
    $gatlingInfluxConfig = "gatling-config\gatling.conf";
    #Configure Docker-compose parameters
    (Get-Content -Path $filePath) -replace '%GATLING_TEST_PATH%', $gatlingTest | Set-Content $filePathCopy
    (Get-Content -Path $filePathCopy) -replace '%GATLING_CONFIG_PATH%', $gatlingResources | Set-Content $filePathCopy
    (Get-Content -Path $filePathCopy) -replace '%GATLING_SIMULATION_TEST_PATH%', $gatlingSimulations | Set-Content $filePathCopy
    (Get-Content -Path $filePathCopy) -replace '%GATLING_SIMULATION_RESULTS_PATH%', $gatlingResults | Set-Content $filePathCopy
    (Get-Content -Path $filePathCopy) -replace '%GATLING_LOGS_PATH%', $gatlingLogs | Set-Content $filePathCopy
    (Get-Content -Path $filePathCopy) -replace '%GATLING_INFLUX_CONFIG_PATH%', $gatlingInfluxConfig | Set-Content $filePathCopy
    (Get-Content -Path $filePathCopy) -replace '%GATLING_LOGBACK_PATH%', $gatlingLogback | Set-Content $filePathCopy
    #Replace docker-compose file with repository gatling solution
    Copy-Item -Path $filePathCopy -Destination $location\docker-compose.yml -PassThru
    Remove-Item $filePathCopy;
}

Write-Host "===> Start Docker Services up" -ForegroundColor Green
docker-compose pull
Write-Host "===> Build Services" -ForegroundColor Green;
docker-compose up -d

Write-Host "==> Initial Database" -ForegroundColor Green
docker exec -it influxdb influx -username admin -password admin -execute 'CREATE DATABASE graphite;'

Write-Host "==> Done" -ForegroundColor Green
Write-Host "==> Next Step:" -ForegroundColor Yellow
Write-Host "Setup your dashboard by visiting http://localhost:3000" -ForegroundColor Green
