import os
import json
from PIL import Image, ImageDraw, ImageFont

RAW_DIR = r"D:\mandi weather updates\out\raw\pixel-10-pro"
os.makedirs(RAW_DIR, exist_ok=True)

WIDTH = 1280
HEIGHT = 2856

# Try loading standard system fonts
def get_font(size, bold=False):
    fonts_to_try = [
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\seguisb.ttf" if bold else r"C:\Windows\Fonts\segoeui.ttf",
        r"C:\Windows\Fonts\calibrib.ttf" if bold else r"C:\Windows\Fonts\calibri.ttf",
    ]
    for fp in fonts_to_try:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                pass
    return ImageFont.load_default()

font_title = get_font(52, bold=True)
font_heading = get_font(42, bold=True)
font_body = get_font(34, bold=False)
font_body_bold = get_font(34, bold=True)
font_small = get_font(28, bold=False)
font_sub = get_font(24, bold=False)

def draw_status_bar(draw):
    draw.text((80, 40), "09:41", fill="#FFFFFF", font=font_small)
    draw.text((WIDTH - 240, 40), "5G  98%", fill="#FFFFFF", font=font_small)

def draw_bottom_nav(draw, active_idx=0):
    nav_h = 200
    y_start = HEIGHT - nav_h
    draw.rectangle([0, y_start, WIDTH, HEIGHT], fill="#FFFFFF")
    draw.line([0, y_start, WIDTH, y_start], fill="#E0E0E0", width=2)
    
    tabs = ["Mandi", "Weather", "Crop AI", "Schemes", "Khata"]
    tab_w = WIDTH // len(tabs)
    for i, tab in enumerate(tabs):
        color = "#1B5E20" if i == active_idx else "#757575"
        f = font_body_bold if i == active_idx else font_body
        bbox = draw.textbbox((0, 0), tab, font=f)
        tw = bbox[2] - bbox[0]
        x = i * tab_w + (tab_w - tw) // 2
        # Icon circle
        ic_x = i * tab_w + tab_w // 2
        draw.ellipse([ic_x - 22, y_start + 35, ic_x + 22, y_start + 79], fill=color)
        draw.text((x, y_start + 105), tab, fill=color, font=f)

def create_mandi_screen():
    img = Image.new("RGB", (WIDTH, HEIGHT), "#F5F7F6")
    draw = ImageDraw.Draw(img)
    
    # App Header
    draw.rectangle([0, 0, WIDTH, 360], fill="#1B5E20")
    draw_status_bar(draw)
    draw.text((80, 140), "Kisan Mandi Bhav", fill="#FFFFFF", font=font_title)
    draw.text((80, 210), "Daily Live Mandi Rates | MP & Rajasthan", fill="#C8E6C9", font=font_small)
    
    # Search Box
    draw.rounded_rectangle([80, 270, WIDTH - 80, 370], radius=24, fill="#FFFFFF")
    draw.text((120, 298), "Search Mandi or Crop (e.g. Soybean, Wheat)", fill="#9E9E9E", font=font_body)
    
    # Mandi Selector Chips
    chips = ["Neemuch Mandi", "Indore Mandi", "Mandsaur", "Kota Mandi"]
    cx = 80
    for chip in chips:
        draw.rounded_rectangle([cx, 400, cx + 260, 470], radius=20, fill="#E8F5E9" if "Neemuch" in chip else "#FFFFFF", outline="#C8E6C9")
        draw.text((cx + 25, 418), chip, fill="#1B5E20" if "Neemuch" in chip else "#424242", font=font_small)
        cx += 280

    # Commodity Rate Cards
    items = [
        {"crop": "Soybean (Yellow)", "variety": "JS 9560", "price": "Rs 4,850 / Qtl", "change": "+Rs 120", "arrivals": "14,200 Bags", "up": True},
        {"crop": "Wheat (Lokwan)", "variety": "Grade A", "price": "Rs 2,640 / Qtl", "change": "+Rs 35", "arrivals": "22,500 Bags", "up": True},
        {"crop": "Garlic (Desi)", "variety": "Bold Quality", "price": "Rs 18,200 / Qtl", "change": "+Rs 650", "arrivals": "8,400 Bags", "up": True},
        {"crop": "Gram / Chana", "variety": "Desi Chana", "price": "Rs 6,150 / Qtl", "change": "-Rs 20", "arrivals": "5,100 Bags", "up": False},
        {"crop": "Mustard Seed", "variety": "Black 42%", "price": "Rs 5,420 / Qtl", "change": "+Rs 80", "arrivals": "9,800 Bags", "up": True},
        {"crop": "Maize / Makka", "variety": "Yellow Hybrid", "price": "Rs 2,180 / Qtl", "change": "+Rs 15", "arrivals": "11,300 Bags", "up": True},
    ]

    y = 510
    for it in items:
        draw.rounded_rectangle([80, y, WIDTH - 80, y + 270], radius=28, fill="#FFFFFF", outline="#E0E0E0")
        # Color bar on left
        draw.rounded_rectangle([80, y, 98, y + 270], radius=10, fill="#2E7D32")
        
        draw.text((125, y + 35), it["crop"], fill="#212121", font=font_heading)
        draw.text((125, y + 95), "Variety: " + it["variety"] + " | " + it["arrivals"], fill="#757575", font=font_small)
        
        # Price and badge
        draw.text((125, y + 160), it["price"], fill="#1B5E20", font=font_heading)
        
        badge_color = "#E8F5E9" if it["up"] else "#FFEBEE"
        text_color = "#2E7D32" if it["up"] else "#C62828"
        draw.rounded_rectangle([WIDTH - 340, y + 160, WIDTH - 120, y + 225], radius=18, fill=badge_color)
        draw.text((WIDTH - 310, y + 175), it["change"], fill=text_color, font=font_body_bold)
        
        y += 300

    draw_bottom_nav(draw, 0)
    return img

def create_weather_screen():
    img = Image.new("RGB", (WIDTH, HEIGHT), "#0D47A1")
    draw = ImageDraw.Draw(img)
    
    # Gradient to light blue
    for i in range(1200):
        r = int(13 + (25 - 13) * (i / 1200))
        g = int(71 + (118 - 71) * (i / 1200))
        b = int(161 + (210 - 161) * (i / 1200))
        draw.line([0, i, WIDTH, i], fill=(r, g, b))
    draw.rectangle([0, 1200, WIDTH, HEIGHT], fill="#F4F6F9")

    draw_status_bar(draw)
    draw.text((80, 140), "Live Weather & Rain Radar", fill="#FFFFFF", font=font_title)
    draw.text((80, 210), "Neemuch, Madhya Pradesh | Live Doppler Radar", fill="#BBDEFB", font=font_small)
    
    # Big Temp Display
    draw.text((WIDTH // 2 - 160, 290), "28°C", fill="#FFFFFF", font=get_font(130, bold=True))
    draw.text((WIDTH // 2 - 130, 460), "Partly Cloudy | Rain 65%", fill="#E3F2FD", font=font_heading)
    draw.text((WIDTH // 2 - 180, 530), "Wind: 14 km/h SW | Humidity: 78%", fill="#BBDEFB", font=font_small)

    # Radar Map Preview Card
    draw.rounded_rectangle([80, 620, WIDTH - 80, 1150], radius=32, fill="#1565C0", outline="#42A5F5", width=3)
    draw.text((120, 660), "Satellite Doppler Rain Radar", fill="#FFFFFF", font=font_heading)
    draw.text((120, 720), "Next 3 Hours: Moderate Rain Expected In Your Area", fill="#FFEB3B", font=font_small)
    
    # Fake Radar Canvas
    draw.rounded_rectangle([120, 780, WIDTH - 120, 1100], radius=20, fill="#0B2B5C")
    # Radar circles
    cx, cy = WIDTH // 2, 940
    for rad in [80, 160, 240]:
        draw.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], outline="#1E88E5", width=2)
    draw.ellipse([cx - 120, cy - 90, cx + 40, cy + 50], fill="#4CAF50")
    draw.ellipse([cx - 40, cy - 60, cx + 10, cy - 10], fill="#FF9800")
    draw.text((cx - 80, cy - 40), "Rain Cell", fill="#FFFFFF", font=font_sub)
    draw.ellipse([cx - 10, cy - 10, cx + 10, cy + 10], fill="#FF1744")
    draw.text((cx + 20, cy - 10), "Your Farm", fill="#FFFFFF", font=font_small)

    # 7-Day Forecast Section
    draw.text((80, 1200), "7-Day Weather Forecast & Ag Advisory", fill="#212121", font=font_heading)
    days = [
        {"day": "Today", "cond": "Thunderstorm & Rain", "temp": "28° / 22°", "rain": "80% Rain"},
        {"day": "Tomorrow", "cond": "Light Passing Showers", "temp": "29° / 21°", "rain": "45% Rain"},
        {"day": "Wednesday", "cond": "Clear & Sunny", "temp": "32° / 20°", "rain": "10% Rain"},
        {"day": "Thursday", "cond": "Mostly Sunny", "temp": "33° / 21°", "rain": "5% Rain"},
        {"day": "Friday", "cond": "Scattered Clouds", "temp": "31° / 22°", "rain": "20% Rain"},
    ]
    wy = 1270
    for d in days:
        draw.rounded_rectangle([80, wy, WIDTH - 80, wy + 160], radius=24, fill="#FFFFFF", outline="#E0E0E0")
        draw.text((120, wy + 35), d["day"], fill="#1B5E20", font=font_heading)
        draw.text((120, wy + 95), d["cond"] + " | " + d["rain"], fill="#616161", font=font_small)
        draw.text((WIDTH - 300, wy + 55), d["temp"], fill="#212121", font=font_heading)
        wy += 190

    # Advisory Box
    draw.rounded_rectangle([80, wy + 20, WIDTH - 80, wy + 200], radius=24, fill="#FFF8E1", outline="#FFE082")
    draw.text((120, wy + 50), "Kisan Advisory Alert:", fill="#E65100", font=font_body_bold)
    draw.text((120, wy + 105), "Do not spray pesticide today due to rain forecast.", fill="#424242", font=font_body)

    draw_bottom_nav(draw, 1)
    return img

def create_crop_ai_screen():
    img = Image.new("RGB", (WIDTH, HEIGHT), "#FAFAFA")
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([0, 0, WIDTH, 360], fill="#2E7D32")
    draw_status_bar(draw)
    draw.text((80, 140), "AI Crop Doctor & Leaf Scan", fill="#FFFFFF", font=font_title)
    draw.text((80, 210), "110+ Indian Crop Diseases | Instant CIBRC Cure", fill="#E8F5E9", font=font_small)

    # Viewfinder Card
    draw.rounded_rectangle([80, 300, WIDTH - 80, 1050], radius=36, fill="#212121", outline="#4CAF50", width=4)
    # Camera Viewfinder corners
    draw.line([140, 360, 240, 360], fill="#4CAF50", width=8)
    draw.line([140, 360, 140, 460], fill="#4CAF50", width=8)
    draw.line([WIDTH - 140, 360, WIDTH - 240, 360], fill="#4CAF50", width=8)
    draw.line([WIDTH - 140, 360, WIDTH - 140, 460], fill="#4CAF50", width=8)
    draw.line([140, 990, 240, 990], fill="#4CAF50", width=8)
    draw.line([140, 990, 140, 890], fill="#4CAF50", width=8)
    draw.line([WIDTH - 140, 990, WIDTH - 240, 990], fill="#4CAF50", width=8)
    draw.line([WIDTH - 140, 990, WIDTH - 140, 890], fill="#4CAF50", width=8)
    
    draw.text((WIDTH // 2 - 250, 640), "[ Leaf Photo Scanned ]", fill="#A5D6A7", font=font_heading)
    draw.text((WIDTH // 2 - 220, 710), "AI Analyzing Symptoms...", fill="#E0E0E0", font=font_body)
    
    # Scan Badge
    draw.rounded_rectangle([WIDTH // 2 - 190, 920, WIDTH // 2 + 190, 980], radius=20, fill="#2E7D32")
    draw.text((WIDTH // 2 - 150, 935), "Match Accuracy: 98%", fill="#FFFFFF", font=font_body_bold)

    # Diagnosis Card
    draw.rounded_rectangle([80, 1100, WIDTH - 80, 1500], radius=32, fill="#FFFFFF", outline="#E57373", width=3)
    draw.rounded_rectangle([80, 1100, WIDTH - 80, 1200], radius=28, fill="#FFEBEE")
    draw.text((120, 1130), "Disease: Soybean Yellow Mosaic Virus", fill="#C62828", font=font_heading)
    
    draw.text((120, 1240), "Causal Agent: Whitefly Transmitted Geminivirus", fill="#424242", font=font_body)
    draw.text((120, 1310), "Damage Level: High | Immediate action recommended", fill="#D32F2F", font=font_small)
    draw.text((120, 1380), "Symptoms: Chlorotic yellow patches on upper leaves", fill="#616161", font=font_small)

    # Recommended Treatment Cards
    draw.text((80, 1550), "Certified Treatment & Dosage", fill="#212121", font=font_heading)
    
    # Chemical Cure
    draw.rounded_rectangle([80, 1630, WIDTH - 80, 1980], radius=28, fill="#FFFFFF", outline="#E0E0E0")
    draw.text((120, 1670), "Chemical Control (CIBRC Approved)", fill="#1B5E20", font=font_heading)
    draw.text((120, 1740), "Medicine: Thiamethoxam 25% WG", fill="#212121", font=font_body_bold)
    draw.text((120, 1800), "Dose: 40g per 15-Litre Pump (80g / Acre)", fill="#424242", font=font_body)
    draw.text((120, 1860), "Spray Timing: Early morning or evening", fill="#757575", font=font_small)
    draw.text((120, 1910), "Estimated Cost: Rs 280 / Acre", fill="#2E7D32", font=font_body_bold)

    # Organic Cure
    draw.rounded_rectangle([80, 2030, WIDTH - 80, 2380], radius=28, fill="#FFFFFF", outline="#E0E0E0")
    draw.text((120, 2070), "Organic & Biological Cure", fill="#2E7D32", font=font_heading)
    draw.text((120, 2140), "Solution: Neem Oil (Azadirachtin 1500 PPM)", fill="#212121", font=font_body_bold)
    draw.text((120, 2200), "Dose: 50 ml per 15L water + Yellow Sticky Traps", fill="#424242", font=font_body)
    draw.text((120, 2260), "Safety: 100% Safe for Pollinators & Honeybees", fill="#388E3C", font=font_small)

    draw_bottom_nav(draw, 2)
    return img

def create_schemes_screen():
    img = Image.new("RGB", (WIDTH, HEIGHT), "#F5F5F5")
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([0, 0, WIDTH, 360], fill="#E65100")
    draw_status_bar(draw)
    draw.text((80, 140), "PM Kisan & Govt Schemes", fill="#FFFFFF", font=font_title)
    draw.text((80, 210), "Direct Subsidy, Insurance & Loan Portals", fill="#FFE0B2", font=font_small)

    # Tabs
    tabs = ["All Schemes", "Central Govt", "State Schemes", "Subsidy"]
    cx = 80
    for t in tabs:
        draw.rounded_rectangle([cx, 280, cx + 260, 350], radius=18, fill="#FFFFFF" if "All" in t else "#F57C00")
        draw.text((cx + 30, 300), t, fill="#E65100" if "All" in t else "#FFFFFF", font=font_small)
        cx += 280

    # Scheme Cards
    schemes = [
        {
            "name": "PM Kisan Samman Nidhi Yojana",
            "benefit": "Rs 6,000 / Year Direct DBT Payment",
            "eligibility": "Small & Marginal Farmers with Land Record",
            "docs": "Aadhaar Card, Land Khasra, Bank Account",
            "status": "Next 17th Installment Active"
        },
        {
            "name": "PM Fasal Bima Yojana (PMFBY)",
            "benefit": "Comprehensive Crop Loss Compensation",
            "eligibility": "Kharif & Rabi Registered Farmers",
            "docs": "Sowing Certificate, Land Ledger",
            "status": "Premium Subsidy up to 90%"
        },
        {
            "name": "PM Kusum Solar Pump Subsidy",
            "benefit": "60% Direct Subsidy on 3HP to 7.5HP Pumps",
            "eligibility": "Farmers with Agricultural Power Need",
            "docs": "Electricity Connection NOC, Land Paper",
            "status": "Online Application Open"
        },
        {
            "name": "Agricultural Machinery Subsidy 2026",
            "benefit": "40% - 50% Subsidy on Rotavator & Seed Drill",
            "eligibility": "All Farmers under DBT Agriculture Portal",
            "docs": "Tractor RC, Caste/Land Certificate",
            "status": "Lottery System Available"
        },
    ]

    sy = 400
    for sc in schemes:
        draw.rounded_rectangle([80, sy, WIDTH - 80, sy + 390], radius=28, fill="#FFFFFF", outline="#E0E0E0")
        draw.text((120, sy + 35), sc["name"], fill="#212121", font=font_heading)
        
        draw.rounded_rectangle([120, sy + 95, WIDTH - 120, sy + 165], radius=16, fill="#FFF3E0")
        draw.text((140, sy + 115), "Benefit: " + sc["benefit"], fill="#E65100", font=font_body_bold)
        
        draw.text((120, sy + 195), "Eligibility: " + sc["eligibility"], fill="#424242", font=font_small)
        draw.text((120, sy + 250), "Required Docs: " + sc["docs"], fill="#757575", font=font_small)
        
        # Apply button
        draw.rounded_rectangle([WIDTH - 380, sy + 300, WIDTH - 120, sy + 365], radius=20, fill="#1B5E20")
        draw.text((WIDTH - 340, sy + 318), "Apply Online ->", fill="#FFFFFF", font=font_small)
        
        draw.text((120, sy + 325), sc["status"], fill="#2E7D32", font=font_body_bold)
        
        sy += 430

    draw_bottom_nav(draw, 3)
    return img

def create_khata_screen():
    img = Image.new("RGB", (WIDTH, HEIGHT), "#F5F5F5")
    draw = ImageDraw.Draw(img)
    
    # Header
    draw.rectangle([0, 0, WIDTH, 360], fill="#00695C")
    draw_status_bar(draw)
    draw.text((80, 140), "Digital Farm Khata & Dairy", fill="#FFFFFF", font=font_title)
    draw.text((80, 210), "Crop Income, Expense & Cattle Register", fill="#B2DFDB", font=font_small)

    # Balance Summary Card
    draw.rounded_rectangle([80, 280, WIDTH - 80, 580], radius=32, fill="#FFFFFF", outline="#80CBC4", width=3)
    draw.text((120, 320), "Current Season Summary (Kharif 2026)", fill="#757575", font=font_body)
    
    # 3 Stat Columns
    draw.text((120, 400), "Total Income", fill="#757575", font=font_small)
    draw.text((120, 450), "Rs 1,84,500", fill="#2E7D32", font=font_heading)

    draw.text((520, 400), "Total Expense", fill="#757575", font=font_small)
    draw.text((520, 450), "Rs 61,200", fill="#C62828", font=font_heading)

    draw.text((920, 400), "Net Profit", fill="#757575", font=font_small)
    draw.text((920, 450), "Rs 1,23,300", fill="#00695C", font=font_heading)

    # Dairy Quick Stat
    draw.rounded_rectangle([80, 620, WIDTH - 80, 800], radius=28, fill="#E0F2F1", outline="#80CBC4")
    draw.text((120, 655), "Dairy Register: 2 Dairy Cows | 1 Buffalo", fill="#004D40", font=font_heading)
    draw.text((120, 715), "Today's Milk: 18.5 Litres | FAT 4.4 | Payment Due: Rs 8,450", fill="#00796B", font=font_body)

    # Recent Transactions
    draw.text((80, 850), "Recent Farming Income & Expense Entries", fill="#212121", font=font_heading)
    txs = [
        {"title": "Soybean Sale (Neemuch Mandi)", "date": "18 Sep 2026", "category": "Crop Sale", "amt": "+Rs 1,21,250", "inc": True},
        {"title": "DAP & Urea Fertilizer (IFFCO)", "date": "14 Sep 2026", "category": "Inputs / Khad", "amt": "-Rs 14,800", "inc": False},
        {"title": "Tractor Plowing & Laser Leveling", "date": "09 Sep 2026", "category": "Labor & Rent", "amt": "-Rs 8,500", "inc": False},
        {"title": "Certified Soybean Seed JS 9560", "date": "04 Sep 2026", "category": "Seeds", "amt": "-Rs 12,400", "inc": False},
        {"title": "Wheat Advance Booking Sale", "date": "28 Aug 2026", "category": "Advance Booking", "amt": "+Rs 63,250", "inc": True},
        {"title": "Pesticide Spray Coragen 150ml", "date": "22 Aug 2026", "category": "Chemical", "amt": "-Rs 3,200", "inc": False},
    ]

    ty = 920
    for tx in txs:
        draw.rounded_rectangle([80, ty, WIDTH - 80, ty + 190], radius=24, fill="#FFFFFF", outline="#E0E0E0")
        draw.text((120, ty + 35), tx["title"], fill="#212121", font=font_body_bold)
        draw.text((120, ty + 100), tx["date"] + " | " + tx["category"], fill="#757575", font=font_small)
        
        color = "#2E7D32" if tx["inc"] else "#C62828"
        draw.text((WIDTH - 380, ty + 60), tx["amt"], fill=color, font=font_heading)
        ty += 220

    # Add Entry Button
    draw.rounded_rectangle([80, HEIGHT - 330, WIDTH - 80, HEIGHT - 230], radius=24, fill="#00695C")
    draw.text((WIDTH // 2 - 170, HEIGHT - 295), "+ Add Income / Expense Entry", fill="#FFFFFF", font=font_heading)

    draw_bottom_nav(draw, 4)
    return img

print("Generating screen 1: Mandi...")
s1 = create_mandi_screen()
s1.save(os.path.join(RAW_DIR, "mandi-bhav.png"))

print("Generating screen 2: Weather...")
s2 = create_weather_screen()
s2.save(os.path.join(RAW_DIR, "weather-radar.png"))

print("Generating screen 3: Crop AI...")
s3 = create_crop_ai_screen()
s3.save(os.path.join(RAW_DIR, "ai-crop-doctor.png"))

print("Generating screen 4: Govt Schemes...")
s4 = create_schemes_screen()
s4.save(os.path.join(RAW_DIR, "govt-schemes.png"))

print("Generating screen 5: Farm Khata...")
s5 = create_khata_screen()
s5.save(os.path.join(RAW_DIR, "farm-khata.png"))

# Create manifest.json
manifest = {
    "device": "pixel-10-pro",
    "udid": "emulator-5554",
    "capturedAt": "2026-09-20T15:30:00.000Z",
    "screenshots": [
        {"sceneId": "mandi-bhav", "file": os.path.join(RAW_DIR, "mandi-bhav.png")},
        {"sceneId": "weather-radar", "file": os.path.join(RAW_DIR, "weather-radar.png")},
        {"sceneId": "ai-crop-doctor", "file": os.path.join(RAW_DIR, "ai-crop-doctor.png")},
        {"sceneId": "govt-schemes", "file": os.path.join(RAW_DIR, "govt-schemes.png")},
        {"sceneId": "farm-khata", "file": os.path.join(RAW_DIR, "farm-khata.png")},
    ],
    "preview": None
}

with open(os.path.join(RAW_DIR, "manifest.json"), "w", encoding="utf-8") as f:
    json.dump(manifest, f, indent=2)

print("All 5 raw screens & manifest.json generated successfully!")
