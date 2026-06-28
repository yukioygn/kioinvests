#!/bin/bash
cd ~/Desktop/kioinvests
python3 -c "
import urllib.request, csv, json, ssl, datetime
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
for ticker in ['SOC', 'UEC', 'EWBC']:
    req = urllib.request.Request(
        f'https://query1.finance.yahoo.com/v8/finance/chart/{ticker}?interval=1d&range=10y',
        headers={'User-Agent': 'Mozilla/5.0'}
    )
    with urllib.request.urlopen(req, context=ctx) as r:
        data = json.load(r)
    result = data['chart']['result'][0]
    timestamps = result['timestamp']
    closes = result['indicators']['quote'][0]['close']
    filename = f'{ticker.lower()}_prices.csv'
    with open(filename, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['Date', 'Close'])
        for ts, p in zip(timestamps, closes):
            if p: w.writerow([datetime.datetime.fromtimestamp(ts).strftime('%-m/%-d/%Y'), round(p,2)])
"
