#!/usr/bin/env python3
import json
import calendar
import datetime
import subprocess

def get_calendar():
    now = datetime.datetime.now()
    today = now.day
    msg = f"<b>{now.strftime('%B %Y')}</b>\n\n"
    
    # Create text calendar
    cal = calendar.TextCalendar(calendar.MONDAY)
    month_str = cal.formatmonth(now.year, now.month, w=0, l=0)
    
    # Remove the first line (Month Year) as we added a bold one
    lines = month_str.split('\n')[1:]
    
    # Highlight today
    # Find the day number in the string and wrap it in span
    # This is a bit tricky with simple string replacement as '1' matches '10', '11' etc.
    # So we rebuild the calendar line by line or use a more robust regex if needed.
    # For simplicity/robustness in a "scratch" script, let's process lines.
    
    final_cal = []
    header = lines[0] # Mo Tu We ...
    final_cal.append(f"<span color='#cba6f7'><b>{header}</b></span>")
    
    for line in lines[1:]:
        if not line.strip():
            continue
        # Split into days (width 2 + 1 space)
        # TextCalendar.formatmonth uses 2 width for days? Actually it depends. 
        # usually " 1  2  3"
        # Let's write our own simple formatter to be sure.
        pass

    # Re-implmenting robust highlight
    cal_lines = []
    
    # Header
    weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    cal_lines.append(" ".join([f"<span color='#89b4fa'><b>{day}</b></span>" for day in weekdays]))
    
    # Days
    month_cal = cal.monthdayscalendar(now.year, now.month)
    for week in month_cal:
        week_str = []
        for day in week:
            if day == 0:
                week_str.append("  ")
            elif day == today:
                week_str.append(f"<span color='#f38ba8'><b>{day:2}</b></span>")
            else:
                week_str.append(f"{day:2}")
        cal_lines.append(" ".join(week_str))
        
    tooltip = msg + "\n".join(cal_lines)
    
    output = {
        "text": f"  {now.strftime('%a, %d %b')}",
        "tooltip": tooltip,
        "class": "calendar",
        "alt": now.strftime("%Y-%m-%d")
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    get_calendar()
