const APP_ROOT = "d:/mandi weather updates";

const config = {
  appRoot: APP_ROOT,
  appPath: "d:/mandi weather updates/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk",
  bundleId: "com.kisanmitra.kisan_mitra",
  android: {
    appPath: "d:/mandi weather updates/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk",
    applicationId: "com.kisanmitra.kisan_mitra",
  },
  devices: ["pixel-10-pro"],
  locales: ["en-US"],
  appearance: "light",
  frame: { variant: "17-pro-blue" },
  theme: {
    background: "linear-gradient(160deg, #1B5E20 0%, #2E7D32 50%, #4CAF50 100%)",
    headlineColor: "#FFFFFF",
    subheadColor: "#E8F5E9",
    fontFamily: 'system-ui, -apple-system, sans-serif',
    copyHeightRatio: 0.24,
    deviceWidthRatio: 0.84,
    template: "editorial",
    layout: "classic",
  },
  store: {
    name: "Kisan Mandi Bhav & Weather",
    subtitle: { "en-US": "Mandi Rates, Weather & AI Crop" },
    developer: "AgriTech India",
    category: "Weather & Agriculture",
    rating: 4.9,
    ratingCount: "5K+ Ratings",
    ageRating: "3+",
    price: "Free",
    description: {
      "en-US": "Daily live Mandi rates across India, 7-day weather forecast & radar, AI leaf disease doctor, government agriculture schemes, and digital farm ledger."
    },
  },
  scenes: [
    {
      kind: "screenshot",
      id: "mandi-bhav",
      headline: { "en-US": "Daily Live Mandi Rates" },
      subhead: { "en-US": "300+ Mandi rates, arrivals & price trends" },
    },
    {
      kind: "screenshot",
      id: "weather-radar",
      headline: { "en-US": "7-Day Weather & Live Radar" },
      subhead: { "en-US": "Rain alerts, temperature & satellite radar" },
    },
    {
      kind: "screenshot",
      id: "ai-crop-doctor",
      headline: { "en-US": "Instant AI Crop Disease Doctor" },
      subhead: { "en-US": "110+ crop diseases & certified cure" },
    },
    {
      kind: "screenshot",
      id: "govt-schemes",
      headline: { "en-US": "Govt Farmer Schemes" },
      subhead: { "en-US": "PM Kisan eligibility, benefits & direct apply" },
    },
    {
      kind: "screenshot",
      id: "farm-khata",
      headline: { "en-US": "Digital Farm Khata & Dairy" },
      subhead: { "en-US": "Income, expense & cattle health logs" },
    },
  ],
};

export default config;
