# Variables
$vmUser = "infini-ops"
$vmIp = "127.0.0.1"
$sshPort = 2222
$sshKeyPath = "your\path\.ssh\id_rsa"
$remotePath = "/home/infini-ops/infinidat"
$healthCheckUrl = "http://127.0.0.1:5000/health"

# Check if user is in docker group
Write-Host "Checking Docker group membership..."
$checkGroup = ssh -i "$sshKeyPath" -p $sshPort "$vmUser@$vmIp" "id | grep -q 'docker'"
if ($LASTEXITCODE -ne 0) {
    Write-Host "User is not in docker group, adding..."
    ssh -i "$sshKeyPath" -p $sshPort "$vmUser@$vmIp" "sudo usermod -aG docker $vmUser && sudo reboot"

    # Wait for reboot
    Write-Host "Waiting for VM to reboot and SSH to become available..."
    $maxTries = 30
    $tryCount = 0
    $sshReady = $false
    do {
        Start-Sleep -Seconds 5
        $sshOutput = & ssh -i "$sshKeyPath" -p $sshPort -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$vmUser@$vmIp" "echo ready" 2>$null
        $sshReady = $sshOutput -eq "ready"
        $tryCount++
    } until ($sshReady -or $tryCount -ge $maxTries)

    if (-not $sshReady) {
        Write-Host "VM did not respond to SSH after reboot. Aborting."
        exit 1
    }

    Start-Sleep -Seconds 10
    Write-Host "VM is back online and SSH is ready."
}

# Create target folder on VM
Write-Host "Ensuring deployment directory exists..."
ssh -i "$sshKeyPath" -p $sshPort "$vmUser@$vmIp" "mkdir -p '$remotePath'"

# Upload project files
Write-Host "Uploading project files to VM..."
scp -i "$sshKeyPath" -P $sshPort -r * "${vmUser}@${vmIp}:$remotePath"

# Define the remote command to start the app
$remoteCmd = "cd ${remotePath} && ls -l && sudo docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v '${remotePath}:${remotePath}' -w ${remotePath} docker/compose:1.29.2 up -d"

# Build and run containers (with docker-compose install check)
Write-Host "Running docker-compose on VM..."
ssh -i "$sshKeyPath" -p $sshPort $vmUser@$vmIp $remoteCmd

# Execute remote setup
ssh -i "$sshKeyPath" -p $sshPort $vmUser@$vmIp $remoteCmd

# Health check
Write-Host "Checking health endpoint..."
Start-Sleep -Seconds 10
$response = Invoke-WebRequest -Uri $healthCheckUrl -UseBasicParsing -ErrorAction SilentlyContinue

if ($response -and $response.StatusCode -eq 200) {
    Write-Host "App is running. Health check passed."
} else {
    Write-Host "Health check failed."
    if ($response) {
        Write-Host "Status code: $($response.StatusCode)"
    } else {
        Write-Host "No response received from $healthCheckUrl"
    }
}
