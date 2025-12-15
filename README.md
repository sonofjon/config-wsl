# config-wsl
Configurations for WSL

## WSL MTU Fix Service

This setup provides a permanent solution for network connectivity issues,
specifically **SSH connection hangs** that occur in **WSL2 Ubuntu
instances** when connected via a **VPN** over a restrictive network (such as
a mobile hotspot).

### The Problem & The Solution

Connectivity failure is caused by an **MTU mismatch**. The combined overhead
from the cellular network's inherent low MTU (e.g., 1420 bytes) and the
VPN's encapsulation headers forces the overall packet size above the actual
**Path MTU Limit** (e.g., 1378 bytes). This leads to fragmentation and
packet loss during the SSH key exchange phase.

The solution is to manually set the WSL network interface (`eth0`) MTU to a
smaller, "safe" value (e.g., 1270 to 1350), ensuring the traffic fits within
the restricted path limit.

* **`wsl_mtu_fix.sh`:** Bash script that sets a reduced MTU value.
* **`wsl-mtu-fix.service`:** Systemd service that executes the MTU fix
  script automatically every time the WSL instance starts.

### Usage and Installation

1.  **Install Script:**
    ```bash
    sudo cp wsl-mtu-fix.sh /usr/local/etc/
    ```
2.  **Install Service:**
    ```bash
    sudo cp wsl-mtu-fix.service /etc/systemd/system/
    ```
3.  **Reload, Enable, and Start the Service:**
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable wsl-mtu-fix.service
    sudo systemctl start wsl-mtu-fix.service
    ```

### Verification and Diagnostics

* **Verify Fix:** Run `wsl --shutdown` (Windows Host) then restart WSL.
    ```bash
    ip link show eth0
    # Check that 'mtu' is set to your <SAFE_MTU> value.
    ```
* **Host Adapter Check:** List local adapter MTU for diagnostics.
    ```powershell
    Get-NetAdapter | Format-Table -AutoSize Name, InterfaceDescription, LinkSpeed, MTUSize
    ```

### Find the Acceptable MTU Limit

Before installation, you must determine the maximum safe MTU for your
network path. This is done on the **Windows Host** while connected to the
VPN and Hotspot.

1.  **Run Path MTU Discovery Test:** Find the largest successful data size
    (LSDS) using the Don't Fragment flag (`-f`).
    ```powershell
    # Example: Ping your server's IP
    ping -f -l 1350 10.142.30.148
    ```
    The buffer size is the size of the data payload *only*. The system
    automatically adds 28 bytes (for IP and ICMP headers) to get the total
    packet size.

2.  **Calculate Safe WSL MTU:** Subtract a 100-byte safety buffer (for VPN
    overhead) from the Path MTU Limit (LSDS + 28 headers).
    {Safe MTU} = {LSDS} + 28 - 100
    *Example: If LSDS is 1350, the Safe MTU is 1278 bytes.*

### Alternative solution

If you're on Windows 11 with a recent WSL version, Microsoft introduced
"Mirrored Network Mode" specifically to improve VPN compatibility. But note
that some VPN clients manage the host's networking stack in such an
aggressive way that they prevent the necessary internal Hyper-V changes
required for mirrored mode.

Add:

```
[wsl2]
networkingMode=mirrored
```

to `$env:USERPROFILE\.wslconfig`.

This setup may also require:

```
hostAddressLoopback=true
```

Note that `networkingMode` and `hostAddressLoopback` can also be enabled in
WSL settings in the Windows start menu.

Finally you may need to open the firewall:

```
Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultInboundAction Allow
```

as described in the documentation below.

Note that manipulation of MTU might still be required.

### References

[Why do I have no internet connection on Ubuntu WSL while on a VPN?]{https://superuser.com/questions/1630487/why-do-i-have-no-internet-connection-on-ubuntu-wsl-while-on-a-vpn}
[Mirrored Networking]{https://learn.microsoft.com/en-us/windows/wsl/networking#mirrored-mode-networking}
[Windows Subsystem for Linux September 2023 update]{https://devblogs.microsoft.com/commandline/windows-subsystem-for-linux-september-2023-update/}
