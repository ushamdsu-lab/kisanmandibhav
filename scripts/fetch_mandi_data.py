#!/usr/bin/env python3
"""
Hourly Mandi Data Sync Script for Kisan Mandi Bhav
Fetches live data from Data.gov.in AGMARKNET API and saves to assets/data/mandi_live_rates.json
"""

import json
import urllib.request
import urllib.parse
import os
import sys
from datetime import datetime, timezone

API_KEY = os.environ.get('MANDI_API_KEY', '579b464db66ec23bdd000001592db4fa842b480f7171a34c0956c64d')
RESOURCE_ID = '9ef84268-d588-465a-a308-a864a43d0070'
BASE_URL = f'https://api.data.gov.in/resource/{RESOURCE_ID}'

OUTPUT_FILE = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'assets', 'data', 'mandi_live_rates.json')

def fetch_all_mandi_rates():
    limit = 5000
    params = {
        'api-key': API_KEY,
        'format': 'json',
        'limit': str(limit),
        'offset': '0',
    }
    url = f"{BASE_URL}?{urllib.parse.urlencode(params)}"
    print(f"Fetching live mandi data from {BASE_URL}...")

    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0 (compatible; KisanMandiBhavSync/1.0)'}
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            if response.status != 200:
                print(f"Error: API returned HTTP {response.status}")
                return None
            data = json.loads(response.read().decode('utf-8'))
            records = data.get('records', [])
            total = data.get('total', len(records))
            print(f"Successfully fetched {len(records)} records (Total on portal: {total})")
            
            output_data = {
                'status': 'ok',
                'total': total,
                'count': len(records),
                'updated_at_utc': datetime.now(timezone.utc).isoformat(),
                'updated_at_ist': datetime.now().strftime('%Y-%m-%d %H:%M:%S IST'),
                'records': records,
            }
            return output_data
    except Exception as e:
        print(f"Error fetching data: {e}")
        return None

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
