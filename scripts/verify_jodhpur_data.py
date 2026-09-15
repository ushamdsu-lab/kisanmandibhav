import json

with open('assets/data/mandi_live_rates.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

records = data.get('records', [])
jodhpur_records = [
    r for r in records
    if 'jodhpur' in r.get('district', '').lower() or 'jodhpur' in r.get('market', '').lower()
]

print(f"=== VERIFIED JODHPUR RECORDS FROM OFFICIAL DATA.GOV.IN (Total: {len(jodhpur_records)}) ===")
for i, r in enumerate(jodhpur_records, 1):
    state = r.get('state')
    dist = r.get('district')
    market = r.get('market')
    crop = r.get('commodity')
    variety = r.get('variety')
    min_p = r.get('min_price')
    max_p = r.get('max_price')
    modal_p = r.get('modal_price')
    date = r.get('arrival_date')
    print(f"{i:2d}. {crop} ({variety}) | Modal: Rs.{modal_p} (Min: Rs.{min_p}, Max: Rs.{max_p}) | Mandi: {market} | District: {dist} | Date: {date}")

print("\n=== NEIGHBORING DISTRICTS REPORTING IN DATA.GOV.IN ===")
neighbor_districts = ['Pali', 'Beawar', 'Nagaur', 'Barmer', 'Jaisalmer', 'Jalore']
for nd in neighbor_districts:
    nd_recs = [r for r in records if nd.lower() in r.get('district', '').lower() and 'rajasthan' in r.get('state', '').lower()]
    markets = set(r.get('market') for r in nd_recs)
    print(f"- {nd}: {len(nd_recs)} records across markets: {sorted(list(markets))}")
