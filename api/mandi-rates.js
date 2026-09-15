// Vercel Serverless Edge API for Kisan Mandi Bhav
// High-Speed Edge CDN & In-Memory Filtering Backend
// Resolves timeouts by serving synced master dataset with < 150ms latency

const DATA_GOV_API_KEY = process.env.MANDI_API_KEY || '579b464db66ec23bdd000001592db4fa842b480f7171a34c0956c64d';
const RESOURCE_ID = '9ef84268-d588-465a-a308-a864a43d0070';
const GOV_BASE_URL = `https://api.data.gov.in/resource/${RESOURCE_ID}`;

// Synced master dataset CDN URL (updated every 15-30 mins via GitHub Actions)
const CDN_DATASET_URL = 'https://cdn.jsdelivr.net/gh/ushamdsu-lab/kisanmandibhav@main/assets/data/mandi_live_rates.json';

// In-memory cache across warm serverless invocations
let globalCache = {
  records: [],
  timestamp: 0,
  updatedAtIst: '',
};

const CACHE_TTL_MS = 10 * 60 * 1000; // 10 minutes in-memory refresh

async function loadDataset() {
  const now = Date.now();
  if (globalCache.records && globalCache.records.length > 0 && (now - globalCache.timestamp) < CACHE_TTL_MS) {
    return globalCache;
  }

  try {
    const timestamp = Math.floor(now / (1000 * 60 * 15)); // 15-min cache-busting
    const cdnRes = await fetch(`${CDN_DATASET_URL}?v=${timestamp}`, {
      headers: { 'User-Agent': 'KisanMandiBhav-Edge/2.0' },
    });

    if (cdnRes.ok) {
      const data = await cdnRes.json();
      if (data && Array.isArray(data.records) && data.records.length > 0) {
        globalCache = {
          records: data.records,
          timestamp: now,
          updatedAtIst: data.updated_at_ist || new Date().toISOString(),
        };
        return globalCache;
      }
    }
  } catch (err) {
    console.warn('[Vercel Edge] CDN fetch error, checking fallback:', err.message);
  }

  return globalCache;
}

module.exports = async (req, res) => {
  // CORS configuration
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');
  
  // Edge CDN caching: 10 mins edge cache, 24h stale-while-revalidate
  res.setHeader('Cache-Control', 'public, max-age=180, s-maxage=600, stale-while-revalidate=86400');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const {
    state,
    district,
    market,
    commodity,
    limit = '5000',
    offset = '0',
    source = 'auto',
  } = req.query;

  const numLimit = Math.max(1, Math.min(parseInt(limit, 10) || 5000, 35000));
  const numOffset = Math.max(0, parseInt(offset, 10) || 0);

  // 1. Try High-Speed Synced Dataset (CDN + Edge memory)
  if (source !== 'direct_gov') {
    const dataset = await loadDataset();
    if (dataset && dataset.records && dataset.records.length > 0) {
      let filtered = dataset.records;

      if (state && state.trim()) {
        const qState = state.trim().toLowerCase();
        filtered = filtered.filter(r => (r.state || '').toLowerCase() === qState || (r.state || '').toLowerCase().includes(qState));
      }

      if (district && district.trim()) {
        const qDist = district.trim().toLowerCase();
        filtered = filtered.filter(r => (r.district || '').toLowerCase() === qDist || (r.district || '').toLowerCase().includes(qDist));
      }

      if (market && market.trim()) {
        const qMkt = market.trim().toLowerCase();
        filtered = filtered.filter(r => (r.market || '').toLowerCase().includes(qMkt));
      }

      if (commodity && commodity.trim()) {
        const qComm = commodity.trim().toLowerCase();
        filtered = filtered.filter(r => (r.commodity || '').toLowerCase().includes(qComm));
      }

      const totalMatches = filtered.length;
      const paginatedRecords = filtered.slice(numOffset, numOffset + numLimit);

      return res.status(200).json({
        status: 'ok',
        engine: 'Kisan Mandi High-Speed Edge CDN',
        cached_at: dataset.updatedAtIst,
        state: state || 'All States',
        total: totalMatches,
        count: paginatedRecords.length,
        offset: numOffset,
        limit: numLimit,
        records: paginatedRecords,
      });
    }
  }

  // 2. Direct Fallback to data.gov.in AGMARKNET API (with 8-second safety timeout)
  try {
    const params = new URLSearchParams({
      'api-key': DATA_GOV_API_KEY,
      'format': 'json',
      'limit': String(Math.min(numLimit, 5000)),
      'offset': String(numOffset),
    });

    if (state && state.trim()) params.append('filters[state]', state.trim());
    if (district && district.trim()) params.append('filters[district]', district.trim());
    if (market && market.trim()) params.append('filters[market]', market.trim());
    if (commodity && commodity.trim()) params.append('filters[commodity]', commodity.trim());

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 8000);

    const apiUrl = `${GOV_BASE_URL}?${params.toString()}`;
    const response = await fetch(apiUrl, {
      signal: controller.signal,
      headers: { 'User-Agent': 'KisanMandiBhav-VercelEdge/2.0' },
    });
    clearTimeout(timeoutId);

    if (!response.ok) {
      throw new Error(`Data.gov.in responded with status: ${response.status}`);
    }

    const data = await response.json();
    const records = data.records || [];

    return res.status(200).json({
      status: 'ok',
      engine: 'Direct data.gov.in Agmarknet API',
      cached_at: new Date().toISOString(),
      state: state || 'All States',
      total: data.total || records.length,
      count: records.length,
      offset: numOffset,
      limit: numLimit,
      records: records,
    });
  } catch (error) {
    console.error('Error fetching mandi data:', error);
    return res.status(500).json({
      status: 'error',
      message: error.message || 'Failed to fetch mandi rates',
      fallback_hint: 'Use local asset or jsDelivr CDN fallback',
    });
  }
};
