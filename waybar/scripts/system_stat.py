#!/usr/bin/env python3
import time
import json
import os

def get_cpu_usage():
    try:
        with open('/proc/stat', 'r') as f:
            line = f.readline()
        parts = line.split()
        # id: cpu user nice system idle iowait irq softirq steal guest guest_nice
        idle = float(parts[4])
        total = sum(float(x) for x in parts[1:])
        return idle, total
    except:
        return 0, 0

def get_mem_usage():
    mem = {}
    try:
        with open('/proc/meminfo', 'r') as f:
            for line in f:
                parts = line.split()
                if len(parts) >= 2:
                    mem[parts[0].rstrip(':')] = int(parts[1])
        
        total = mem.get('MemTotal', 1)
        avail = mem.get('MemAvailable', 0)
        used_percent = ((total - avail) / total) * 100
        return used_percent, total, avail
    except:
        return 0, 1, 1

def get_cpu_temp():
    try:
        # Try finding thermal zone for x86_pkg_temp or similar
        # Fallback to thermal_zone0
        term_path = "/sys/class/thermal/thermal_zone0/temp"
        # Check common paths if zone0 fails or is weird
        for i in range(5):
             path = f"/sys/class/thermal/thermal_zone{i}/type"
             if os.path.exists(path):
                 with open(path, 'r') as f:
                     type_name = f.read().strip()
                 if 'x86_pkg_temp' in type_name or 'acpitz' in type_name:
                     term_path = f"/sys/class/thermal/thermal_zone{i}/temp"
                     break
        
        with open(term_path, 'r') as f:
            temp = int(f.read().strip()) / 1000.0
        return temp
    except:
        return 0

def main():
    # First measurement
    idle1, total1 = get_cpu_usage()
    time.sleep(0.5)
    # Second measurement
    idle2, total2 = get_cpu_usage()
    
    cpu_usage = 0
    if total2 - total1 > 0:
        cpu_usage = (1 - (idle2 - idle1) / (total2 - total1)) * 100

    mem_percent, mem_total, mem_avail = get_mem_usage()
    temp = get_cpu_temp()
    
    # Format output
    text = f" {cpu_usage:.0f}%   {mem_percent:.0f}%   {temp:.0f}°C"
    
    # Determine class based on thresholds
    css_class = "normal"
    if cpu_usage > 80 or mem_percent > 85 or temp > 80:
        css_class = "critical"
    elif cpu_usage > 50 or mem_percent > 60 or temp > 65:
        css_class = "warning"
        
    tooltip = (f"<b>CPU:</b> {cpu_usage:.1f}%\n"
               f"<b>Memory:</b> {mem_percent:.1f}% ({((mem_total - mem_avail)/1024/1024):.1f}GB / {(mem_total/1024/1024):.1f}GB)\n"
               f"<b>Temp:</b> {temp:.1f}°C")
               
    output = {
        "text": text,
        "tooltip": tooltip,
        "class": css_class,
        "alt": "enabled"
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()
