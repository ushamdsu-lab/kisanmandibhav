#!/usr/bin/env python3
"""
Hourly Mandi Data Sync Script for Kisan Mandi Bhav
Fetches comprehensive live data state-by-state from Data.gov.in AGMARKNET API
covering all 36 States & UTs, merges with master database, and saves optimized JSON.
"""

import json
import urllib.request
import urllib.parse
import os
import sys
import time
from datetime import datetime, timezone

API_KEY = os.environ.get('MANDI_API_KEY', '579b464db66ec23bdd000001592db4fa842b480f7171a34c0956c64d')
RESOURCE_ID = '9ef84268-d588-465a-a308-a864a43d0070'
BASE_URL = f'https://api.data.gov.in/resource/{RESOURCE_ID}'

OUTPUT_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'assets', 'data', 'mandi_live_rates.json')

# Complete list of all 36 Indian States and Union Territories with known data.gov.in spelling variations
BASE_TARGET_STATES = [
    # Major Agricultural States
    'Rajasthan',
    'Madhya Pradesh',
    'Uttar Pradesh',
    'Haryana',
    'Punjab',
    'Gujarat',
    'Maharashtra',
    'Bihar',
    'Karnataka',
    'Telangana',
    'Andhra Pradesh',
    'West Bengal',
    'Odisha',
    'Himachal Pradesh',
    'Uttarakhand',
    'Chattisgarh',
    'Chhattisgarh',
    'Jharkhand',
    'Tamil Nadu',
    'Keralam',
    'Kerala',
    
    # North-East & Eastern States
    'Assam',
    'Tripura',
    'Meghalaya',
    'Manipur',
    'Nagaland',
    'Mizoram',
    'Arunachal Pradesh',
    'Sikkim',

    # Western & Southern States / UTs
    'Goa',
    'NCT of Delhi',
    'Jammu and Kashmir',
    'Chandigarh',
    'Andaman and Nicobar',
    'Andaman and Nicobar Islands',
    'Puducherry',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Ladakh',
]

def discover_active_states():
    """
    Scans recent live records on data.gov.in to discover all currently active state names.
    This dynamically catches any new or modified state spelling in real time.
    """
    discovered = set(BASE_TARGET_STATES)
    print("Discovering active states dynamically from data.gov.in...")
    for offset in [0, 5000]:
        params = {
            'api-key': API_KEY,
            'format': 'json',
            'limit': '1000',
            'offset': str(offset),
        }
        url = f"{BASE_URL}?{urllib.parse.urlencode(params)}"
        req = urllib.request.Request(
            url,
            headers={'User-Agent': 'Mozilla/5.0 (compatible; KisanMandiBhavSync/2.0)'}
        )
        try:
            with urllib.request.urlopen(req, timeout=20) as response:
                if response.status == 200:
                    d = json.loads(response.read().decode('utf-8'))
                    for rec in d.get('records', []):
                        st = rec.get('state')
                        if st and st.strip():
                            discovered.add(st.strip())
        except Exception as e:
            print(f"  [Notice] Discovery probe at offset {offset}: {e}")
        time.sleep(0.5)

    print(f"Total target states/UTs to sync: {len(discovered)}")
    return sorted(list(discovered))

def fetch_records_for_state(state_name):
    """
    Fetches all records for a given state using batch pagination (limit 2000).
    Keeps offset strictly within data.gov.in's safe index range (< 10000).
    """
    all_recs = []
    offset = 0
    batch_size = 2000
    max_safe_offset = 8000

    while offset <= max_safe_offset:
        params = {
            'api-key': API_KEY,
            'format': 'json',
            'limit': str(batch_size),
            'offset': str(offset),
            'filters[state]': state_name,
        }
        url = f"{BASE_URL}?{urllib.parse.urlencode(params)}"
        req = urllib.request.Request(
            url,
            headers={'User-Agent': 'Mozilla/5.0 (compatible; KisanMandiBhavSync/2.0)'}
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode('utf-8'))
                    records = data.get('records', [])
                    total = data.get('total', 0)
                    all_recs.extend(records)
                    offset += len(records)
                    if not records or len(all_recs) >= total or len(records) < batch_size:
                        break
                else:
                    break
        except Exception as e:
            print(f"  [Warning] Error fetching {state_name} (offset {offset}): {e}, retrying in 2s...")
            time.sleep(2.0)
            try:
                with urllib.request.urlopen(req, timeout=35) as response:
                    if response.status == 200:
                        data = json.loads(response.read().decode('utf-8'))
                        records = data.get('records', [])
                        total = data.get('total', 0)
                        all_recs.extend(records)
                        offset += len(records)
                        if not records or len(all_recs) >= total or len(records) < batch_size:
                            break
            except Exception as e2:
                print(f"  [Error] Retry failed for {state_name}: {e2}")
                break
        time.sleep(0.4)
    return all_recs

def load_existing_master():
    """
    Loads existing master file so that mandis that haven't reported yet today
    retain their latest known prices.
    """
    if not os.path.exists(OUTPUT_FILE):
        return {}
    try:
        with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
            records = data.get('records', [])
            master_dict = {}
            for r in records:
                key = (
                    str(r.get('state', '')).strip().lower(),
                    str(r.get('district', '')).strip().lower(),
                    str(r.get('market', '')).strip().lower(),
                    str(r.get('commodity', '')).strip().lower(),
                )
                if key[0] and key[2]:
                    master_dict[key] = r
            print(f"Loaded {len(master_dict)} existing master mandi records.")
            return master_dict
    except Exception as e:
        print(f"Could not load existing master file: {e}")
        return {}

def fetch_all_mandi_rates():
    print(f"Starting All-India Mandi Data Sync from {BASE_URL}...")
    
    # 1. Load existing master records to prevent loss of non-updated mandis
    master_records = load_existing_master()

    # 2. Discover all active states dynamically
    target_states = discover_active_states()

    live_count = 0
    today_records = []

    # 3. Fetch each state
    for state in target_states:
        recs = fetch_records_for_state(state)
        if recs:
            for r in recs:
                key = (
                    str(r.get('state', '')).strip().lower(),
                    str(r.get('district', '')).strip().lower(),
                    str(r.get('market', '')).strip().lower(),
                    str(r.get('commodity', '')).strip().lower(),
                )
                if key[0] and key[2]:
                    master_records[key] = r
                    live_count += 1
            print(f"  ✓ {state}: {len(recs)} records fetched")
        time.sleep(0.5)

    final_records = list(master_records.values())
    print(f"\nFinal synced dataset: {len(final_records)} total mandi crop records ({live_count} live updates today).")

    return {
        'status': 'ok',
        'total': len(final_records),
        'count': len(final_records),
        'live_synced_today': live_count,
        'updated_at_utc': datetime.now(timezone.utc).isoformat(),
        'updated_at_ist': datetime.now().strftime('%Y-%m-%d %H:%M:%S IST'),
        'records': final_records,
    }

def main():
    data = fetch_all_mandi_rates()
    if not data or not data.get('records'):
        print("Warning: No records fetched or preserved. Aborting save.")
        sys.exit(0)

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    # Save compact JSON without bloated spacing to optimize bandwidth
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))

    size_mb = os.path.getsize(OUTPUT_FILE) / (1024 * 1024)
    print(f"Successfully saved {len(data['records'])} records to {OUTPUT_FILE} ({size_mb:.2f} MB)")

if __name__ == '__main__':
    main()
