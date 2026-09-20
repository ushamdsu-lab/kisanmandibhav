import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BG_PATH = r"C:\Users\msi\.gemini\antigravity-ide\brain\dc2e488d-d902-4cf3-9b82-8d39cbe96589\kisan_mandi_feature_bg_1789922248131.jpg"
REAL_MANDI_SHOT = r"D:\mandi weather updates\out\raw\pixel-10-pro\mandi-bhav.png"
LOGO_PATH = r"D:\mandi weather updates\assets\images\app_logo.png"

OUT_PATH = r"D:\mandi weather updates\out\play_store_feature_graphic_1024x500.png"
OUT_ROOT_PATH = r"D:\mandi weather updates\play_store_feature_graphic_1024x500.png"

W, H = 1024, 500

# 1. Load and resize background image to cover 1024x500
bg_img = Image.open(BG_PATH).convert("RGBA")
# Calculate crop / fill
bg_ratio = bg_img.width / bg_img.height
target_ratio = W / H

if bg_ratio > target_ratio:
    # background is wider, scale to height
    new_h = H
    new_w = int(H * bg_ratio)
else:
    new_w = W
    new_h = int(W / bg_ratio)

bg_resized = bg_img.resize((new_w, new_h), Image.Resampling.LANCZOS)
# Center crop
left = (new_w - W) // 2
top = (new_h - H) // 2
canvas = bg_resized.crop((left, top, left + W, top + H))

# 2. Add an elegant dark emerald / gradient overlay on the left to make text readable
overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
draw_ov = ImageDraw.Draw(overlay)

for x in range(W):
    if x < 450:
        alpha = int(235 * (1 - (x / 750)))
    elif x < 720:
        alpha = int(180 * (1 - ((x - 450) / 270)))
    else:
        alpha = 0
    draw_ov.line([(x, 0), (x, H)], fill=(13, 50, 20, alpha))

canvas = Image.alpha_composite(canvas, overlay)
draw = ImageDraw.Draw(canvas)

# Fonts
def get_font(size, bold=False):
    fonts_to_try = [
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\seguisb.ttf" if bold else r"C:\Windows\Fonts\segoeui.ttf",
    ]
    for fp in fonts_to_try:
        if os.path.exists(fp):
            try:
                return ImageFont.truetype(fp, size)
            except Exception:
                pass
    return ImageFont.load_default()

font_pill = get_font(18, bold=True)
font_title = get_font(48, bold=True)
font_sub = get_font(21, bold=False)
font_badge = get_font(19, bold=True)

# 3. Logo
if os.path.exists(LOGO_PATH):
    try:
        logo = Image.open(LOGO_PATH).convert("RGBA")
        logo = logo.resize((84, 84), Image.Resampling.LANCZOS)
        # Rounded mask for logo
        mask = Image.new("L", (84, 84), 0)
        draw_m = ImageDraw.Draw(mask)
        draw_m.rounded_rectangle([0, 0, 84, 84], radius=20, fill=255)
        canvas.paste(logo, (55, 45), mask=mask)
    except Exception as e:
        print("Logo error:", e)

# Header Tag Pill
draw.rounded_rectangle([155, 65, 375, 108], radius=18, fill="#E8F5E9", outline="#81C784", width=2)
draw.text((172, 76), "100% FREE KRISHI APP", fill="#1B5E20", font=font_pill)

# Main Title
draw.text((55, 150), "Kisan Mandi Bhav", fill="#FFFFFF", font=font_title)
draw.text((55, 212), "Daily Live Mandi Rates & AI Farm Doctor", fill="#A5D6A7", font=get_font(24, bold=True))

# Subtitle
draw.text((55, 268), "देशभर की 300+ मंडियों के लाइव भाव, आवक व ऐतिहासिक चार्ट्स", fill="#E8F5E9", font=font_sub)
draw.text((55, 302), "7-दिवसीय सटीक मौसम रडार • 110+ फसल रोग AI स्कैनर • फार्म खाता", fill="#C8E6C9", font=font_sub)

# 4 Key Feature Pills
pills = [
    ("🌾 300+ Live Mandis", 55, 365, 220),
    ("🌦️ Rain Doppler Radar", 290, 365, 230),
    ("🔬 110+ AI Crop Diseases", 55, 425, 230),
    ("📒 Digital Farm Khata", 300, 425, 210),
]

for text, px, py, pw in pills:
    draw.rounded_rectangle([px, py, px + pw, py + 48], radius=20, fill="#1B5E20", outline="#81C784", width=2)
    draw.text((px + 14, py + 12), text, fill="#FFFFFF", font=font_badge)

# 4. Right side: Device Frame with Real Mandi Screen
if os.path.exists(REAL_MANDI_SHOT):
    real_shot = Image.open(REAL_MANDI_SHOT).convert("RGBA")
    dev_w, dev_h = 245, 460
    shot_resized = real_shot.resize((dev_w, dev_h), Image.Resampling.LANCZOS)
    
    # Phone border/shadow
    bx, by = W - 290, 20
    # Soft shadow
    shadow = Image.new("RGBA", (dev_w + 30, dev_h + 30), (0, 0, 0, 140))
    canvas.paste(shadow, (bx - 10, by - 5), mask=shadow)
    
    # Device bezel
    draw.rounded_rectangle([bx - 6, by - 6, bx + dev_w + 6, by + dev_h + 6], radius=24, fill="#0F172A", outline="#334155", width=3)
    
    # Rounded screen cutout
    screen_mask = Image.new("L", (dev_w, dev_h), 0)
    draw_sm = ImageDraw.Draw(screen_mask)
    draw_sm.rounded_rectangle([0, 0, dev_w, dev_h], radius=18, fill=255)
    
    canvas.paste(shot_resized, (bx, by), mask=screen_mask)

# Save strictly as RGB (No alpha channel required by Google Play)
final_rgb = canvas.convert("RGB")
final_rgb.save(OUT_PATH, "PNG", quality=100)
final_rgb.save(OUT_ROOT_PATH, "PNG", quality=100)

print(f"Feature graphic successfully created: {OUT_PATH} (Dimensions: {final_rgb.size})")
