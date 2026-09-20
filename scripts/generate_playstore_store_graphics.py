import os
from PIL import Image, ImageDraw, ImageFont

ROOT_DIR = r"D:\mandi weather updates"
OUT_DIR = os.path.join(ROOT_DIR, "out")
RAW_DIR = os.path.join(OUT_DIR, "raw", "pixel-10-pro")
LOGO_PATH = os.path.join(ROOT_DIR, "assets", "images", "app_logo.png")

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

def make_feature_graphic():
    w, h = 1024, 500
    img = Image.new("RGB", (w, h), "#1B5E20")
    draw = ImageDraw.Draw(img)

    # Gradient background
    for x in range(w):
        r = int(27 + (46 - 27) * (x / w))
        g = int(94 + (125 - 94) * (x / w))
        b = int(32 + (50 - 32) * (x / w))
        draw.line([x, 0, x, h], fill=(r, g, b))

    # Glow / decoration circles
    draw.ellipse([w - 420, -120, w + 100, h + 120], fill=(46, 125, 50))

    # Paste real logo if exists
    if os.path.exists(LOGO_PATH):
        try:
            logo = Image.open(LOGO_PATH).convert("RGBA")
            logo = logo.resize((90, 90), Image.Resampling.LANCZOS)
            img.paste(logo, (60, 50), mask=logo)
        except Exception as e:
            print("Logo load err:", e)

    font_main = get_font(44, bold=True)
    font_sub = get_font(21, bold=False)
    font_badge = get_font(18, bold=True)
    font_points = get_font(19, bold=True)

    draw.rounded_rectangle([170, 75, 390, 115], radius=16, fill="#E8F5E9")
    draw.text((185, 84), "OFFICIAL KRISHI APP", fill="#1B5E20", font=font_badge)

    draw.text((60, 160), "Kisan Mandi Bhav", fill="#FFFFFF", font=font_main)
    draw.text((60, 220), "& Live Weather Radar", fill="#A5D6A7", font=font_main)

    draw.text((60, 290), "Daily Live Mandi Rates | 7-Day Weather & Radar Maps", fill="#E8F5E9", font=font_sub)
    draw.text((60, 320), "AI Crop Doctor (110+ Diseases) | PM Kisan & Govt Schemes", fill="#C8E6C9", font=font_sub)

    features = [
        " 300+ Live Mandis",
        " Doppler Weather",
        " AI Crop Doctor",
        " Farm Khata",
    ]
    px = 60
    for feat in features:
        draw.rounded_rectangle([px, 390, px + 210, 445], radius=20, fill="#2E7D32", outline="#81C784")
        draw.text((px + 14, 404), feat, fill="#FFFFFF", font=font_points)
        px += 230

    # Real Mandi Screen preview thumbnail on right
    real_mandi_path = os.path.join(RAW_DIR, "mandi-bhav.png")
    if os.path.exists(real_mandi_path):
        mandi_img = Image.open(real_mandi_path).convert("RGBA")
        thumb_w, thumb_h = 240, 460
        mandi_thumb = mandi_img.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        # Paste inside a bezel
        bx, by = w - 300, 25
        draw.rounded_rectangle([bx - 10, by - 10, bx + thumb_w + 10, by + thumb_h + 10], radius=26, fill="#0E1B2A")
        img.paste(mandi_thumb.convert("RGB"), (bx, by))

    out_path = os.path.join(OUT_DIR, "play_store_feature_graphic_1024x500.png")
    img.save(out_path, "PNG")
    print("Feature Graphic saved with REAL app screen:", out_path)

def make_app_icon():
    w, h = 512, 512
    if os.path.exists(LOGO_PATH):
        try:
            logo = Image.open(LOGO_PATH).convert("RGBA")
            icon = logo.resize((w, h), Image.Resampling.LANCZOS)
            # Remove alpha channel for Play Store
            bg = Image.new("RGB", (w, h), "#FFFFFF")
            bg.paste(icon, (0, 0), mask=icon)
            out_path = os.path.join(OUT_DIR, "play_store_icon_512.png")
            bg.save(out_path, "PNG")
            print("App icon saved from real app logo:", out_path)
            return
        except Exception as e:
            print("Error creating icon from real logo:", e)

make_feature_graphic()
make_app_icon()
