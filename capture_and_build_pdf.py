import json
import base64
import time
import os
import urllib.request
import websocket
from PIL import Image, ImageDraw, ImageFont

def get_page_info():
    # Discover remote debugging port
    for port in [61852, 53322]:
        try:
            req = urllib.request.urlopen(f"http://127.0.0.1:{port}/json", timeout=2)
            pages = json.loads(req.read().decode('utf-8'))
            for p in pages:
                if p.get('type') == 'page' and 'localhost' in p.get('url', ''):
                    return port, p['webSocketDebuggerUrl'], p['url']
        except Exception:
            continue
    raise RuntimeError("Could not find Chrome page")

SCREENS = [
    {
        "id": "home",
        "title": "1. Consumer Home Screen",
        "module": "Consumer Experience",
        "desc": "Real-time salon discovery, quick category filters, live queue status, and nearby pilot locations."
    },
    {
        "id": "explore",
        "title": "2. Salon Explore & Filter Screen",
        "module": "Consumer Experience",
        "desc": "Detailed directory of partner salons with live wait times, distance, pricing, and guaranteed slots."
    },
    {
        "id": "salon_detail",
        "title": "3. Salon Profile & Slot Picker",
        "module": "Consumer Experience",
        "desc": "Full salon profile with stylist roster, live available time slots, ratings, and service catalog."
    },
    {
        "id": "service_time",
        "title": "4. Service Time Options",
        "module": "Consumer Experience",
        "desc": "Flexible booking options: Now (immediate walk-in), Within 30 min, 1 Hour, Tomorrow, or Custom calendar."
    },
    {
        "id": "book_by_time",
        "title": "5. Book By Time Slot",
        "module": "Consumer Experience",
        "desc": "Instant slot booking matrix matching customer schedules with salon chairs."
    },
    {
        "id": "last_minute",
        "title": "6. Last-Minute Openings",
        "module": "Consumer Experience",
        "desc": "Urgent openings in the next 90 minutes with green/amber live status badges."
    },
    {
        "id": "booking_confirmation",
        "title": "7. Booking Confirmation & Token",
        "module": "Consumer Experience",
        "desc": "Instant appointment token, travel buffer estimator, address directions, and payment summary."
    },
    {
        "id": "live_appointment",
        "title": "8. Live Queue Tracker Screen",
        "module": "Consumer Experience",
        "desc": "Real-time queue tracking ('You are Next'), estimated chair start time, and turn notifications."
    },
    {
        "id": "bookings",
        "title": "9. My Bookings Screen",
        "module": "Consumer Experience",
        "desc": "Overview of active appointments and past salon visits with instant re-book capability."
    },
    {
        "id": "profile",
        "title": "10. Consumer Profile Screen",
        "module": "Consumer Experience",
        "desc": "User preferences, saved salons, payment methods, and account settings."
    },
    {
        "id": "location_picker",
        "title": "11. Location Picker Screen",
        "module": "Consumer Experience",
        "desc": "Bhubaneswar pilot areas (Saheed Nagar, Patia/KIIT, Jayadev Vihar, Nayapalli, Chandrasekharpur)."
    },
    {
        "id": "partner_dashboard",
        "title": "12. Partner Dashboard Screen",
        "module": "Partner Management",
        "desc": "Live salon queue counter, today's appointments, active stylist status, and quick action tools."
    },
    {
        "id": "manage_slots",
        "title": "13. Manage Slots Availability",
        "module": "Partner Management",
        "desc": "Interactive slot matrix allowing salon managers to toggle slot status (available/booked/blocked)."
    },
    {
        "id": "staff_management",
        "title": "14. Staff Roster & Status",
        "module": "Partner Management",
        "desc": "Real-time stylist status switcher (Available, With Customer, On Break, Off) and shift timings."
    },
    {
        "id": "add_walk_in",
        "title": "15. Add Walk-In Guest",
        "module": "Partner Management",
        "desc": "Quick walk-in check-in form adding physical guests directly to the live digital queue."
    },
    {
        "id": "customer_crm",
        "title": "16. Customer CRM & History",
        "module": "Partner Management",
        "desc": "Client records, visit frequency, VIP loyalty status, and service notes."
    },
    {
        "id": "during_service",
        "title": "17. During Service Live Chair",
        "module": "Partner Management",
        "desc": "In-chair active service timer, add-on service upsell options, and instant checkout invoice."
    },
    {
        "id": "incoming_bookings",
        "title": "18. Incoming Bookings Dispatch",
        "module": "Partner Management",
        "desc": "Live dispatch alert for incoming bookings with accept/reject controls."
    },
    {
        "id": "analytics",
        "title": "19. Salon Business Analytics",
        "module": "Partner Management",
        "desc": "Key operational metrics: daily revenue, chair utilization rate, peak hour trends, and client retention."
    }
]

def capture_all():
    port, ws_url, base_url = get_page_info()
    base_clean = base_url.split('?')[0].rstrip('/')
    print(f"Connecting to Chrome on port {port}...")
    ws = websocket.create_connection(ws_url, timeout=10, suppress_origin=True)

    msg_id = 1
    def send_cmd(method, params=None):
        nonlocal msg_id
        cmd = {"id": msg_id, "method": method, "params": params or {}}
        ws.send(json.dumps(cmd))
        msg_id += 1
        while True:
            resp = json.loads(ws.recv())
            if resp.get("id") == cmd["id"]:
                return resp.get("result", {})

    # Set mobile viewport emulation
    send_cmd("Emulation.setDeviceMetricsOverride", {
        "width": 390,
        "height": 844,
        "deviceScaleFactor": 2,
        "mobile": True
    })

    out_dir = os.path.join(os.getcwd(), "screenshots_output")
    os.makedirs(out_dir, exist_ok=True)

    captured_files = []

    print("Beginning screen captures...")
    for idx, sc in enumerate(SCREENS):
        target_url = f"{base_clean}/?screen={sc['id']}"
        print(f"[{idx+1}/{len(SCREENS)}] Capturing: {sc['title']}...")
        send_cmd("Page.navigate", {"url": target_url})
        time.sleep(1.8) # Allow Flutter to settle and render

        res = send_cmd("Page.captureScreenshot", {"format": "png"})
        img_bytes = base64.b64decode(res["data"])

        img_path = os.path.join(out_dir, f"{idx+1:02d}_{sc['id']}.png")
        with open(img_path, "wb") as f:
            f.write(img_bytes)

        captured_files.append((sc, img_path))

    ws.close()
    print(f"All {len(captured_files)} screenshots captured successfully!")

    # Build PDF
    print("Compiling into Zalono_App_Screenshots.pdf...")
    pdf_pages = []

    # A4 dimensions at 150 DPI: 1240 x 1754 px
    PAGE_W = 1240
    PAGE_H = 1754

    for sc, img_path in captured_files:
        page = Image.new("RGB", (PAGE_W, PAGE_H), color=(248, 249, 250))
        draw = ImageDraw.Draw(page)

        # Header Bar
        draw.rectangle([(0, 0), (PAGE_W, 110)], fill=(90, 10, 30)) # Zalono Burgundy
        draw.text((60, 24), "ZALONO", fill=(255, 255, 255))
        draw.text((60, 58), "Real-Time Salon Booking & Live Slots Platform", fill=(230, 210, 215))
        draw.text((PAGE_W - 320, 40), f"Module: {sc['module']}", fill=(255, 255, 255))

        # Screen Title and Description
        draw.text((60, 135), sc["title"], fill=(25, 25, 25))
        draw.text((60, 175), sc["desc"], fill=(80, 80, 80))

        # Screenshot Frame
        screenshot = Image.open(img_path)
        # Target size to fit cleanly on A4
        max_h = 1340
        aspect = screenshot.width / screenshot.height
        new_h = max_h
        new_w = int(new_h * aspect)

        screenshot_resized = screenshot.resize((new_w, new_h), Image.Resampling.LANCZOS)
        x_pos = (PAGE_W - new_w) // 2
        y_pos = 220

        # Subtle shadow / border box around mobile screen
        draw.rectangle([(x_pos - 4, y_pos - 4), (x_pos + new_w + 4, y_pos + new_h + 4)], fill=(210, 210, 215))
        page.paste(screenshot_resized, (x_pos, y_pos))

        # Footer
        draw.rectangle([(0, PAGE_H - 45), (PAGE_W, PAGE_H)], fill=(235, 235, 240))
        draw.text((60, PAGE_H - 32), "Zalono Pilot Release • Confidential", fill=(120, 120, 120))
        draw.text((PAGE_W - 200, PAGE_H - 32), f"Page {captured_files.index((sc, img_path)) + 1} of {len(captured_files)}", fill=(120, 120, 120))

        pdf_pages.append(page)

    pdf_path = os.path.join(os.getcwd(), "Zalono_App_Screenshots.pdf")
    if pdf_pages:
        pdf_pages[0].save(
            pdf_path,
            save_all=True,
            append_images=pdf_pages[1:],
            resolution=150.0
        )
        print(f"✅ Generated PDF document: {pdf_path} ({len(pdf_pages)} pages)")

if __name__ == "__main__":
    capture_all()
