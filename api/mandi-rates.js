// Vercel Serverless Edge API for Kisan Mandi Bhav
// Fetches live AGMARKNET mandi rates from data.gov.in with intelligent Edge CDN caching.

const DATA_GOV_API_KEY = process.env.MANDI_API_KEY || '579b464db66ec23bdd000001592db4fa842b480f7171a34c0956c64d';
const RESOURCE_ID = '9ef84268-d588-465a-a308-a864a43d0070';
const BASE_URL = `https://api.data.gov.in/resource/${RESOURCE_ID}`;

module.exports = async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');
  
  // Set Edge CDN caching headers: Cache for 30 minutes, allow stale while revalidating for 24h
  res.setHeader('Cache-Control', 'public, max-age=300, s-maxage=1800, stale-while-revalidate=86400');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const { state, district, market, commodity, limit = '5000', offset = '0' } = req.query;

  try {
    const params = new URLSearchParams({
      'api-key': DATA_GOV_API_KEY,
      'format': 'json',
      'limit': String(limit),
      'offset': String(offset),
    });

    if (state && state.trim().length > 0) {
      params.append('filters[state]', state.trim());
    }
    if (district && district.trim().length > 0) {
      params.append('filters[district]', district.trim());
    }
    if (market && market.trim().length > 0) {
      params.append('filters[market]', market.trim());
    }
    if (commodity && commodity.trim().length > 0) {
      params.append('filters[commodity]', commodity.trim());
    }

    const apiUrl = `${BASE_URL}?${params.toString()}`;
    const response = await fetch(apiUrl, {
      headers: {
        'User-Agent': 'KisanMandiBhav-VercelEdge/2.0'
      }
    });

    if (!response.ok) {
      throw new Error(`Data.gov.in responded with status: ${response.status}`);
    }

    const data = await response.json();
    const records = data.records || [];

    return res.status(200).json({
      status: 'ok',
      source: 'data.gov.in Agmarknet API via Vercel Edge CDN',
      cached_at: new Date().toISOString(),
      state: state || 'All States',
      total: data.total || records.length,
      count: records.length,
      records: records,
    });
  } catch (error) {
    console.error('Error fetching data.gov.in:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Failed to fetch mandi rates from data.gov.in',
      fallback_hint: 'Use local asset or jsDelivr CDN fallback',
    });
  }
};
