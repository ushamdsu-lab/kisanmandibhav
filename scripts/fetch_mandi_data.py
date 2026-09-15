#!/usr/bin/env python3
"""
Hourly Mandi Data Sync Script for Kisan Mandi Bhav
Fetches comprehensive live data state-by-state from Data.gov.in AGMARKNET API
and saves to assets/data/mandi_live_rates.json so every mandi has all its active crops.
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

# Distinct agricultural states exactly matching data.gov.in spellings
TARGET_STATES = [
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
    'Jharkhand',
    'Tamil Nadu',
    'Keralam',
    'NCT of Delhi',
    'Jammu and Kashmir',
]

def fetch_records_for_state(state_name):
    all_recs = []
    offset = 0
    batch_size = 2000
    while True:
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
        time.sleep(0.5)
    return all_recs

def fetch_all_mandi_rates():
    print(f"Fetching comprehensive multi-state mandi rates from {BASE_URL}...")
    combined_records = []
    seen_keys = set()
    total_portal_count = 0

    for state in TARGET_STATES:
        recs = fetch_records_for_state(state)
        new_count = 0
        for r in recs:
            # Key to avoid exact duplicate entries
            key = (
                r.get('state', '').strip().lower(),
                r.get('district', '').strip().lower(),
                r.get('market', '').strip().lower(),
                r.get('commodity', '').strip().lower(),
            )
            if key not in seen_keys:
                seen_keys.add(key)
                combined_records.append(r)
                new_count += 1
        print(f"  - {state}: {new_count} unique crop records")
        time.sleep(1.0)  # Respect data.gov.in API rate limits

    # Fallback to general fetch if state-wise was too small
    if len(combined_records) < 500:
        print("  State-wise fetch small, fetching general 5000 batch as supplement...")
        try:
            params = {'api-key': API_KEY, 'format': 'json', 'limit': '5000', 'offset': '0'}
            url = f"{BASE_URL}?{urllib.parse.urlencode(params)}"
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=30) as response:
                if response.status == 200:
                    d = json.loads(response.read().decode('utf-8'))
                    total_portal_count = d.get('total', 0)
                    for r in d.get('records', []):
                        key = (
                            r.get('state', '').strip().lower(),
                            r.get('district', '').strip().lower(),
                            r.get('market', '').strip().lower(),
                            r.get('commodity', '').strip().lower(),
                        )
                        if key not in seen_keys:
                            seen_keys.add(key)
                            combined_records.append(r)
        except Exception as e:
            print(f"General batch error: {e}")

    print(f"\nSuccessfully collected {len(combined_records)} total unique mandi crop records!")

    return {
        'status': 'ok',
        'total': total_portal_count or len(combined_records),
        'count': len(combined_records),
        'updated_at_utc': datetime.now(timezone.utc).isoformat(),
        'updated_at_ist': datetime.now().strftime('%Y-%m-%d %H:%M:%S IST'),
        'records': combined_records,
    }

def main():
    data = fetch_all_mandi_rates()
    if not data or not data.get('records'):
        print("Warning: No records fetched, preserving existing file.")
        sys.exit(0)

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Saved {len(data['records'])} records to {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
