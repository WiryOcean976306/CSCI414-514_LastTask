
$ApiContainer = "api_server"
$ClientContainer = "game_client"
$ApiUrl = "https://192.168.145.10:8000/health"

$HealthCheckCommand = @"
import ssl
import urllib.request

ctx = ssl._create_unverified_context()
urllib.request.urlopen('$ApiUrl', context=ctx, timeout=5)
"@

Write-Host "=================================="
Write-Host "API AUTOMATION AND RECOVERY"
Write-Host "=================================="

Write-Host "[1] Checking API health..."

docker exec $ClientContainer python3 -c $HealthCheckCommand 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "API is healthy. No recovery needed."
    exit 0
}

Write-Host "API is unavailable."

$ContainerState = docker inspect -f "{{.State.Running}}" $ApiContainer 2>$null

if ($ContainerState -ne "true") {

    Write-Host "[2] Container is stopped. Starting container..."
    docker start $ApiContainer



    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Could not start API container."
        exit 1
    }

    Start-Sleep -Seconds 10
}
else {

    Write-Host "[2] Container running. Restarting Uvicorn..."
    docker exec $ApiContainer pkill -x uvicorn
    Start-Sleep -Seconds 2
    docker exec -d $ApiContainer uvicorn main:app --host 0.0.0.0 --port 8000 --app-dir /

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Could not start Uvicorn."
        exit 1
    }
}

Write-Host "[2] Restarting Uvicorn..."

docker exec $ApiContainer pkill -x uvicorn

Start-Sleep -Seconds 2

docker exec -d $ApiContainer uvicorn main:app --host 0.0.0.0 --port 8000 --app-dir /

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Could not start Uvicorn."
    exit 1
}

Write-Host "[3] Waiting for API recovery..."

for ($attempt = 1; $attempt -le 10; $attempt++) {
    Start-Sleep -Seconds 2

    docker exec $ClientContainer python3 -c $HealthCheckCommand 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: API recovered."
        docker exec $ClientContainer python3 -c "
        import ssl
        import urllib.request

        ctx = ssl._create_unverified_context()
        print(
            urllib.request.urlopen(
                '$ApiUrl',
                context=ctx
            ).read().decode()
        )
        "
        exit 0
    }

    Write-Host "Waiting... attempt $attempt/10"
}

Write-Host "ERROR: API recovery failed."
exit 1
