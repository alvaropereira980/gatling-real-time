
Write-Host "===> Deleting and down docker images" -ForegroundColor Yellow

Write-Host "===> Clean up database" -ForegroundColor Green

#docker exec -it influxdb influx -username admin -password admin -execute 'DROP DATABASE graphite;'

Write-Host "===> Build Services" -ForegroundColor Green

$location = (Get-Location).Path

Write-Host "===> Clean docker-compose" -ForegroundColor Green
docker-compose down

Remove-Item $location\gatling -Recurse -Force

