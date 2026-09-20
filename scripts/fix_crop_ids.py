import json
import sys

sys.stdout.reconfigure(encoding='utf-8')
with open('assets/data/crop_diseases.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

diseases = data.get('diseases', [])
print(f"Total diseases: {len(diseases)}")

# Fix any generic cropIds
fixed_count = 0
for d in diseases:
    cid = d.get('cropId', '')
    cname = d.get('cropName', '').lower()
    if cid in ['fruits', 'commercial', 'vegetables', 'spices']:
        if 'grape' in cname:
            d['cropId'] = 'grapes'
            d['cropHindi'] = 'अंगूर'
            fixed_count += 1
        elif 'ber' in cname:
            d['cropId'] = 'ber'
            d['cropHindi'] = 'बेर'
            fixed_count += 1
        elif 'tea' in cname:
            d['cropId'] = 'tea'
            d['cropHindi'] = 'चाय'
            fixed_count += 1
        elif 'coffee' in cname:
            d['cropId'] = 'coffee'
            d['cropHindi'] = 'कॉफ़ी'
            fixed_count += 1
        elif 'carrot' in cname:
            d['cropId'] = 'carrot'
            d['cropHindi'] = 'गाजर'
            fixed_count += 1
        elif 'radish' in cname:
            d['cropId'] = 'radish'
            d['cropHindi'] = 'मूली'
            fixed_count += 1
        elif 'bottle gourd' in cname or 'bottle_gourd' in cname:
            d['cropId'] = 'bottle_gourd'
            d['cropHindi'] = 'लौकी / घिया'
            fixed_count += 1
        elif 'bitter gourd' in cname or 'bitter_gourd' in cname:
            d['cropId'] = 'bitter_gourd'
            d['cropHindi'] = 'करेला'
            fixed_count += 1
        elif 'spinach' in cname:
            d['cropId'] = 'spinach'
            d['cropHindi'] = 'पालक'
            fixed_count += 1
        elif 'capsicum' in cname:
            d['cropId'] = 'capsicum'
            d['cropHindi'] = 'शिमला मिर्च'
            fixed_count += 1
        elif 'date palm' in cname:
            d['cropId'] = 'date_palm'
            d['cropHindi'] = 'खजूर'
            fixed_count += 1

print(f"Fixed {fixed_count} generic cropIds.")

with open('assets/data/crop_diseases.json', 'w', encoding='utf-8') as f:
    json.dump({'version': '2.0.0', 'total': len(diseases), 'diseases': diseases}, f, ensure_ascii=False, indent=2)

print("Saved updated crop_diseases.json successfully.")
