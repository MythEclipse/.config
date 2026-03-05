#!/home/asephs/.config/waybar/scripts/.venv/bin/python3
import datetime
import os.path
import json
import socket
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/calendar.readonly"]

CREDENTIALS_FILE = os.path.expanduser("~/.config/waybar/scripts/credentials.json")
TOKEN_FILE = os.path.expanduser("~/.config/waybar/scripts/token.json")

def get_credentials():
    creds = None
    if os.path.exists(TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            try:
                creds.refresh(Request())
            except Exception:
                creds = None

        if not creds:
            if not os.path.exists(CREDENTIALS_FILE):
                return None
            
            # If running in a non-interactive environment (like waybar exec), we can't do auth flow
            # We assume the user has run this script manually once
            if not os.isatty(0): # Check if stdin is a terminal
                return "AUTH_REQUIRED"

            try:
                flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_FILE, SCOPES)
                creds = flow.run_local_server(port=0)
                # Save the credentials for the next run
                with open(TOKEN_FILE, "w") as token:
                    token.write(creds.to_json())
            except Exception as e:
                return None
                
    return creds

def main():
    creds = get_credentials()
    
    if creds == "AUTH_REQUIRED":
        print(json.dumps({"text": "Auth Required", "tooltip": "Run ~/.config/waybar/scripts/google_calendar.py manually to authenticate", "class": "auth"}))
        return

    if not creds:
        print(json.dumps({"text": "No Creds", "tooltip": "Missing credentials.json. See Setup Guide.", "class": "error"}))
        return

    try:
        service = build("calendar", "v3", credentials=creds)

        now = datetime.datetime.now(datetime.timezone.utc).isoformat()
        events_result = (
            service.events()
            .list(
                calendarId="primary",
                timeMin=now,
                maxResults=5,
                singleEvents=True,
                orderBy="startTime",
            )
            .execute()
        )
        events = events_result.get("items", [])

        if not events:
            print(json.dumps({"text": "Checking...", "tooltip": "No upcoming events found.", "class": "none"}))
            return

        # Format Tooltip
        tooltip_lines = ["<b>Upcoming Events</b>"]
        next_event_text = ""
        
        for event in events:
            start = event["start"].get("dateTime", event["start"].get("date"))
            summary = event["summary"]
            
            # Parse time
            try:
                dt = datetime.datetime.fromisoformat(start)
                time_str = dt.strftime("%H:%M")
                date_str = dt.strftime("%Y-%m-%d")
                
                # Check if today
                today = datetime.datetime.now().date()
                if dt.date() == today:
                    display_date = "Today"
                elif dt.date() == today + datetime.timedelta(days=1):
                    display_date = "Tomorrow"
                else:
                    display_date = date_str
                
                tooltip_lines.append(f"{display_date} {time_str} - {summary}")
                
                if not next_event_text:
                    diff = dt - datetime.datetime.now(dt.tzinfo)
                    minutes = int(diff.total_seconds() / 60)
                    if minutes < 0:
                        next_event_text = f"Now: {summary}"
                    elif minutes < 60:
                        next_event_text = f"{minutes}m: {summary}"
                    else:
                        next_event_text = f"{time_str} {summary}"

            except ValueError:
                # All day event
                tooltip_lines.append(f"All Day - {summary}")
                if not next_event_text:
                    next_event_text = summary

        # Default text if logic above failed
        if not next_event_text:
            next_event_text = events[0]["summary"]

        # Truncate text
        if len(next_event_text) > 30:
            next_event_text = next_event_text[:27] + "..."

        print(json.dumps({
            "text": f"  {next_event_text}", 
            "tooltip": "\n".join(tooltip_lines), 
            "class": "event"
        }))

    except HttpError as error:
        print(json.dumps({"text": "API Error", "tooltip": str(error), "class": "error"}))
    except Exception as e:
        print(json.dumps({"text": "Error", "tooltip": str(e), "class": "error"}))

if __name__ == "__main__":
    main()
