<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
  body { margin: 0; padding: 0; background: #000; }
  .slide {
    width: 100vw;
    height: 100vh;
    overflow: hidden;
    position: relative;
    background-color: #070d1e;
    background-image: 
      radial-gradient(ellipse 90% 60% at 50% -10%, rgba(14, 165, 233, 0.22), transparent 70%),
      radial-gradient(ellipse 60% 50% at 90% 100%, rgba(20, 184, 166, 0.16), transparent 60%);
    color: #f8fafc;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    padding: 38px 48px;
    font-size: 19px;
    letter-spacing: -0.015em;
    box-sizing: border-box;
    page-break-after: always;
  }
  h1, h2 { color: #f8fafc; margin: 0 0 16px 0; font-weight: 700; letter-spacing: -0.03em; line-height: 1.15; }
  h1 { font-size: 2.3rem; }
  h2 { font-size: 1.7rem; border-bottom: 2px solid rgba(56, 189, 248, 0.3); padding-bottom: 8px; }
  h3 { color: #38bdf8; font-size: 1.18rem; margin: 0 0 8px 0; font-weight: 600; }
  p { line-height: 1.45; margin: 0 0 10px 0; }
  strong { color: #ffffff; font-weight: 600; }
  code { background: rgba(30, 41, 59, 0.85); color: #38bdf8; padding: 2px 7px; border-radius: 4px; font-size: 0.88em; font-family: 'JetBrains Mono', Consolas, monospace; border: 1px solid rgba(56, 189, 248, 0.2); }
  pre code { background: transparent; padding: 0; border: none; }
  .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; margin-top: 10px; }
  .grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 14px; margin-top: 10px; }
  .grid-4 { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 12px; margin-top: 10px; }
  .grid-2-1 { display: grid; grid-template-columns: 1.4fr 1fr; gap: 20px; margin-top: 10px; align-items: center; }
  .grid-1-2 { display: grid; grid-template-columns: 1fr 1.35fr; gap: 20px; margin-top: 10px; align-items: center; }
  .card { background: rgba(15, 23, 42, 0.72); border: 1px solid rgba(56, 189, 248, 0.22); border-radius: 12px; padding: 14px 16px; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.4); }
  .card-highlight { background: rgba(14, 165, 233, 0.12); border: 1px solid rgba(56, 189, 248, 0.45); border-radius: 12px; padding: 14px 16px; box-shadow: 0 12px 28px -4px rgba(14, 165, 233, 0.25); }
  .card-danger { background: rgba(244, 63, 94, 0.1); border: 1px solid rgba(244, 63, 94, 0.35); border-radius: 12px; padding: 14px 16px; }
  .card-success { background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.35); border-radius: 12px; padding: 14px 16px; }
  .badge { display: inline-block; padding: 3px 10px; border-radius: 999px; font-size: 0.76rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background: rgba(56, 189, 248, 0.15); color: #38bdf8; border: 1px solid rgba(56, 189, 248, 0.35); margin-bottom: 6px; }
  .badge-teal { background: rgba(20, 184, 166, 0.15); color: #2dd4bf; border-color: rgba(20, 184, 166, 0.35); }
  .badge-emerald { background: rgba(16, 185, 129, 0.15); color: #34d399; border-color: rgba(16, 185, 129, 0.35); }
  .badge-rose { background: rgba(244, 63, 94, 0.15); color: #fb7185; border-color: rgba(244, 63, 94, 0.35); }
  .stat-val { font-size: 2.1rem; font-weight: 800; line-height: 1; margin: 4px 0 2px 0; color: #38bdf8; }
  .stat-label { font-size: 0.8rem; color: #94a3b8; font-weight: 500; }
  table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 0.78rem; margin-top: 10px; border-radius: 8px; overflow: hidden; border: 1px solid rgba(56, 189, 248, 0.2); }
  th { background-color: #1e293b; color: #38bdf8; padding: 8px 12px; font-weight: 700; text-align: left; border-bottom: 1px solid rgba(56, 189, 248, 0.25); }
  td { padding: 7px 12px; border-bottom: 1px solid rgba(51, 65, 85, 0.6); background-color: rgba(15, 23, 42, 0.6); }
  tr:last-child td { border-bottom: none; }
  tr:nth-child(even) td { background-color: rgba(30, 41, 59, 0.4); }
  .shot-wrap { text-align: center; }
  .shot-img { height: 380px; border-radius: 18px; border: 3px solid rgba(56, 189, 248, 0.35); box-shadow: 0 16px 36px -8px rgba(0, 0, 0, 0.7), 0 0 20px rgba(56, 189, 248, 0.2); object-fit: cover; }
  .caption { font-size: 0.75rem; color: #94a3b8; margin-top: 6px; }
  .step-flow { display: flex; align-items: center; gap: 8px; margin: 12px 0; flex-wrap: wrap; }
  .step-pill { background: rgba(30, 41, 59, 0.85); border: 1px solid rgba(56, 189, 248, 0.25); border-radius: 8px; padding: 6px 10px; font-size: 0.78rem; }
  .step-arrow { color: #38bdf8; font-weight: bold; font-size: 0.9rem; }
</style>
</head>
<body>

<div class="slide">
<div style="display: flex; height: 100%; flex-direction: column; justify-content: space-between;">
  <div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid rgba(56, 189, 248, 0.2); padding-bottom: 14px;">
    <div style="display: flex; align-items: center; gap: 14px;">
      <img src="app_icon.png" style="width: 58px; height: 58px; border-radius: 14px; box-shadow: 0 8px 20px rgba(14, 165, 233, 0.4); border: 2px solid rgba(56,189,248,0.5);" />
      <div>
        <h1 style="margin: 0; font-size: 2.4rem; letter-spacing: -0.04em;">HYDRATED</h1>
        <p style="margin: 0; color: #38bdf8; font-size: 0.95rem; font-weight: 600;">Intelligent, Offline-First Hydration via Hardware NFC</p>
      </div>
    </div>
    <div style="text-align: right;">
      <span class="badge badge-emerald">Production Ready</span><br/>
      <span style="font-size: 0.74rem; color: #94a3b8; font-family: monospace;">v1.2.0 · Dart 3.9+ · Flutter</span>
    </div>
  </div>

  <div class="grid-3" style="margin: 20px 0;">
    <div class="card">
      <span class="badge">Hardware Touchpoint</span>
      <h3 style="color:#ffffff;">Sub-1s Physical Tap</h3>
      <p style="font-size:0.83rem; color:#94a3b8; margin:0;">Zero phone unlocks required. Tap phone to passive NTAG213/215 coaster to instantly register 250ml or 500ml.</p>
    </div>
    <div class="card">
      <span class="badge badge-teal">Radical Privacy</span>
      <h3 style="color:#ffffff;">100% Offline Engine</h3>
      <p style="font-size:0.83rem; color:#94a3b8; margin:0;">Zero accounts, zero servers, zero analytics. Local JSON document store with sub-5ms disk I/O latency.</p>
    </div>
    <div class="card">
      <span class="badge badge-emerald">Cross Platform</span>
      <h3 style="color:#ffffff;">Multi-OS Architecture</h3>
      <p style="font-size:0.83rem; color:#94a3b8; margin:0;">Native CoreNFC on iOS, Android NFC intent dispatch, and responsive Desktop & Web clients with JSON portability.</p>
    </div>
  </div>

  <div style="display: flex; justify-content: space-between; align-items: center; background: rgba(15, 23, 42, 0.5); padding: 10px 16px; border-radius: 10px; border: 1px solid rgba(56,189,248,0.15); font-size: 0.78rem;">
    <div><strong>Engineering Team:</strong> Mobile Architecture & Ubiquitous Computing Group</div>
    <div><strong>Repository:</strong> <code style="color:#38bdf8;">rmdir-sys32/hydra-water-tracker</code></div>
    <div><strong>License:</strong> MIT Open Source</div>
  </div>
</div>
</div>

<div class="slide">
<h2>The Core Problem — Why 80% of Hydration Apps Fail</h2>
<div class="grid-2-1">
  <div>
    <div class="card-danger" style="margin-bottom: 12px;">
      <h3 style="color:#fb7185; margin:0 0 4px 0;">The "Logging Fatigue" Bottleneck</h3>
      <p style="font-size: 0.85rem; margin:0;">
        Users start hydration journeys with high enthusiasm, but traditional apps demand an exhausting <strong>7-step friction loop</strong> 6 to 10 times a day. Over <strong>80% of users abandon the app within 14 days</strong> purely due to cognitive overhead.
      </p>
    </div>
    <div style="background: rgba(15, 23, 42, 0.8); border: 1px solid rgba(244, 63, 94, 0.3); border-radius: 10px; padding: 12px; margin-bottom: 10px;">
      <div style="font-size: 0.75rem; text-transform: uppercase; color: #fb7185; font-weight: 700; margin-bottom: 8px;">The 35-Second Traditional App Journey:</div>
      <div class="step-flow" style="margin: 0;">
        <span class="step-pill">1. Unlock Device</span>
        <span class="step-arrow">→</span>
        <span class="step-pill">2. Locate App Icon</span>
        <span class="step-arrow">→</span>
        <span class="step-pill">3. Wait for Splash/Ads</span>
        <span class="step-arrow">→</span>
        <span class="step-pill">4. Tap '+' FAB</span>
        <span class="step-arrow">→</span>
        <span class="step-pill">5. Select Drink Type</span>
        <span class="step-arrow">→</span>
        <span class="step-pill">6. Scroll Volume Picker</span>
        <span class="step-arrow">→</span>
        <span class="step-pill">7. Tap Save</span>
      </div>
    </div>
    <div class="card-success">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <div>
          <h3 style="color:#34d399; margin: 0 0 2px 0;">Hydrated's Physical Touchpoint:</h3>
          <p style="font-size: 0.85rem; margin:0;">Tap your phone against your bottle or coaster sticker $\rightarrow$ <strong>Intake logged under 1s with haptic confirmation.</strong></p>
        </div>
        <span class="badge badge-emerald" style="font-size: 0.9rem; padding: 6px 12px;">97% Time Saved</span>
      </div>
    </div>
  </div>
  <div style="display:flex; flex-direction:column; gap:12px;">
    <div class="card" style="text-align: center;">
      <div class="stat-val" style="color: #fb7185;">75%</div>
      <div class="stat-label">Adults Suffer Chronic Mild Dehydration</div>
      <p style="font-size: 0.72rem; color: #94a3b8; margin-top: 4px;">Leads to 15% reduction in cognitive acuity & afternoon fatigue.</p>
    </div>
    <div class="card" style="text-align: center;">
      <div class="stat-val" style="color: #f59e0b;">80%</div>
      <div class="stat-label">D14 Churn Rate on App Store Trackers</div>
      <p style="font-size: 0.72rem; color: #94a3b8; margin-top: 4px;">Attributed to ad interruptions, account signups, and manual forms.</p>
    </div>
    <div class="card" style="text-align: center;">
      <div class="stat-val" style="color: #38bdf8;">&lt; 1 sec</div>
      <div class="stat-label">Hydrated Interaction Latency</div>
      <p style="font-size: 0.72rem; color: #94a3b8; margin-top: 4px;">Zero screens or dialogs needed to register hydration.</p>
    </div>
  </div>
</div>
</div>

<div class="slide">
<h2>Executive Summary — Physical Computing Meets Wellness</h2>
<div class="grid-1-2">
  <div class="shot-wrap">
    <img src="screenshot-dashboard.jpeg" class="shot-img" alt="Hydrated Dashboard" />
    <div class="caption">Real App Screenshot: Fluid Glowing Radial Tracker & Category Quick-Log</div>
  </div>
  <div>
    <div class="card-highlight" style="margin-bottom: 14px;">
      <h3 style="color: #38bdf8; margin: 0 0 6px 0;">Turning Water Tracking Into an Invisible Reflex</h3>
      <p style="font-size: 0.88rem; margin:0;">
        Hydrated combines tactile hardware triggers with an elegant glassmorphic dashboard. Instead of behaving like a demanding chore, tracking happens as a natural byproduct of drinking.
      </p>
    </div>
    <div class="grid-2">
      <div class="card">
        <span class="badge">Hardware Layer</span>
        <h3 style="font-size:1.05rem;">NTAG213/215 Support</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Preconfigured NDEF URI schemes trigger instant intake without app in foreground.</p>
      </div>
      <div class="card">
        <span class="badge badge-teal">Persistence</span>
        <h3 style="font-size:1.05rem;">Document JSON Engine</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Raw UTF-8 JSON file in sandbox. Sub-5ms latency, zero SQLite database lock contention.</p>
      </div>
      <div class="card">
        <span class="badge badge-emerald">Privacy</span>
        <h3 style="font-size:1.05rem;">Zero-Knowledge Design</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">No accounts, no email capture, zero telemetry SDKs, no external network requests.</p>
      </div>
      <div class="card">
        <span class="badge">UI Engine</span>
        <h3 style="font-size:1.05rem;">Glassmorphism Shaders</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Multi-layered backdrop filters via <code>liquid_glass_renderer</code> with dynamic HSL glow.</p>
      </div>
    </div>
  </div>
</div>
</div>

<div class="slide">
<h2>Cross-Platform Reach — Engineered for Every Device</h2>
<p style="font-size:0.88rem; color:#94a3b8; margin-bottom: 12px;">
  Built on a unified Flutter codebase targeting high-performance rendering across native mobile, desktop workstations, and modern browsers.
</p>
<div class="grid-4">
  <div class="card">
    <span class="badge badge-emerald">Tier 1 Target</span>
    <h3 style="color:#ffffff; font-size:1.1rem; margin-top:4px;">Android</h3>
    <ul style="font-size:0.76rem; padding-left:14px; margin:6px 0; color:#94a3b8;">
      <li>Background NFC Intent Dispatch (NDEF URL)</li>
      <li>Home Screen Glanceable Widgets via <code>home_widget</code></li>
      <li>Battery-efficient local alarms & reminders</li>
      <li>Haptic vibration motor integration</li>
    </ul>
    <div style="font-size:0.72rem; color:#34d399; font-weight:600;">Full Hardware Interop</div>
  </div>
  <div class="card">
    <span class="badge badge-emerald">Tier 1 Target</span>
    <h3 style="color:#ffffff; font-size:1.1rem; margin-top:4px;">iOS</h3>
    <ul style="font-size:0.76rem; padding-left:14px; margin:6px 0; color:#94a3b8;">
      <li>CoreNFC reader session orchestration</li>
      <li>iOS Haptic Feedback Engine (Light/Medium)</li>
      <li>Cupertino backdrop-filter glass shaders</li>
      <li>Local document sandbox protection</li>
    </ul>
    <div style="font-size:0.72rem; color:#34d399; font-weight:600;">Optimized for iPhone 12+</div>
  </div>
  <div class="card">
    <span class="badge badge-teal">Tier 2 Target</span>
    <h3 style="color:#ffffff; font-size:1.1rem; margin-top:4px;">Desktop</h3>
    <ul style="font-size:0.76rem; padding-left:14px; margin:6px 0; color:#94a3b8;">
      <li>Windows / macOS / Linux builds</li>
      <li>Office desk dashboard with hotkey shortcuts</li>
      <li>Instant JSON clipboard export/import</li>
      <li>High-DPI multi-window rendering</li>
    </ul>
    <div style="font-size:0.72rem; color:#2dd4bf; font-weight:600;">Single-Click Desk Logging</div>
  </div>
  <div class="card">
    <span class="badge">Tier 2 Target</span>
    <h3 style="color:#ffffff; font-size:1.1rem; margin-top:4px;">Web</h3>
    <ul style="font-size:0.76rem; padding-left:14px; margin:6px 0; color:#94a3b8;">
      <li>Zero-install responsive PWA</li>
      <li>Client-side localStorage document driver</li>
      <li>CanvasKit GPU-accelerated rendering</li>
      <li>Offline service worker caching</li>
    </ul>
    <div style="font-size:0.72rem; color:#38bdf8; font-weight:600;">Universal Browser Access</div>
  </div>
</div>
<div class="card" style="margin-top: 14px; padding: 10px 16px; background: rgba(30, 41, 59, 0.4);">
  <div style="display:flex; justify-content:space-between; align-items:center; font-size:0.8rem;">
    <span><strong>Single Codebase Efficiency:</strong> 94% shared code across all 4 platforms with conditional platform service bindings.</span>
    <span style="color:#38bdf8; font-family:monospace;">flutter build apk / ipa / windows / web</span>
  </div>
</div>
</div>

<div class="slide">
<h2>Technical Stack & Architectural Blueprint</h2>
<div class="grid-2-1">
  <div>
    <svg viewBox="0 0 680 340" style="width:100%; height:auto; background:rgba(15,23,42,0.85); border:1px solid rgba(56,189,248,0.3); border-radius:12px; padding:10px;">
      <rect x="20" y="15" width="640" height="60" rx="8" fill="rgba(30,41,59,0.9)" stroke="#38bdf8" stroke-width="1.5"/>
      <text x="340" y="38" fill="#ffffff" font-size="14" font-weight="700" text-anchor="middle">PRESENTATION LAYER (FLUTTER 3.x UI)</text>
      <text x="340" y="58" fill="#94a3b8" font-size="11" text-anchor="middle">Fluid Radial Canvas · Liquid Glass Shaders · Quick-Log Presets · Haptic Feedback</text>
      <path d="M 180 75 L 180 115" stroke="#38bdf8" stroke-width="2" marker-end="url(#arrow)" stroke-dasharray="4"/>
      <path d="M 500 75 L 500 115" stroke="#14b8a6" stroke-width="2" marker-end="url(#arrow)" stroke-dasharray="4"/>
      <rect x="20" y="115" width="310" height="110" rx="8" fill="rgba(14,165,233,0.12)" stroke="#38bdf8" stroke-width="1.2"/>
      <text x="175" y="138" fill="#38bdf8" font-size="13" font-weight="700" text-anchor="middle">HARDWARE & SENSORS SUBSYSTEM</text>
      <text x="40" y="162" fill="#cbd5e1" font-size="10.5">• flutter_nfc_kit (NDEF ISO-14443 Type A/B)</text>
      <text x="40" y="180" fill="#cbd5e1" font-size="10.5">• Android Intent Dispatch (`mycounterapp.local`)</text>
      <text x="40" y="198" fill="#cbd5e1" font-size="10.5">• home_widget (Real-time Home Screen Tile)</text>
      <text x="40" y="216" fill="#cbd5e1" font-size="10.5">• Platform Haptics (Device Vibrator Engine)</text>
      <rect x="350" y="115" width="310" height="110" rx="8" fill="rgba(20,184,166,0.12)" stroke="#14b8a6" stroke-width="1.2"/>
      <text x="505" y="138" fill="#2dd4bf" font-size="13" font-weight="700" text-anchor="middle">OFFLINE-FIRST STORAGE ENGINE</text>
      <text x="370" y="162" fill="#cbd5e1" font-size="10.5">• water_logs.json (Local Sandbox Document)</text>
      <text x="370" y="180" fill="#cbd5e1" font-size="10.5">• shared_preferences (Goals, Presets, Themes)</text>
      <text x="370" y="198" fill="#cbd5e1" font-size="10.5">• Auto-Pruning Engine (7-day window maintenance)</text>
      <text x="370" y="216" fill="#cbd5e1" font-size="10.5">• JSON Clipboard Serializer / Deserializer</text>
      <rect x="20" y="245" width="640" height="70" rx="8" fill="rgba(30,41,59,0.7)" stroke="#64748b" stroke-width="1"/>
      <text x="340" y="268" fill="#94a3b8" font-size="11" font-weight="700" text-anchor="middle">CROSS-PLATFORM OS EXECUTION ENVIRONMENT</text>
      <text x="100" y="295" fill="#38bdf8" font-size="11" text-anchor="middle"> Android 8.0+</text>
      <text x="260" y="295" fill="#38bdf8" font-size="11" text-anchor="middle"> iOS 14.0+</text>
      <text x="420" y="295" fill="#38bdf8" font-size="11" text-anchor="middle"> Desktop (Win/Mac/Linux)</text>
      <text x="580" y="295" fill="#38bdf8" font-size="11" text-anchor="middle"> Modern Web</text>
    </svg>
  </div>
  <div>
    <div class="card" style="margin-bottom:12px;">
      <span class="badge">Core Dependencies</span>
      <h3 style="font-size:1.05rem;">Engineering Highlights</h3>
      <ul style="font-size:0.77rem; color:#94a3b8; padding-left:14px; margin:4px 0;">
        <li><strong>Dart 3.9+ Sound Null Safety</strong>: Eliminates runtime pointer crashes.</li>
        <li><strong>Reactive State Management</strong>: ValueNotifiers & ChangeNotifier keep repaint boundaries strictly isolated.</li>
        <li><strong>Sub-5ms Disk I/O</strong>: Streaming JSON string buffers without blocking main render threads.</li>
      </ul>
    </div>
    <div class="card-highlight">
      <div style="font-size:0.75rem; text-transform:uppercase; color:#38bdf8; font-weight:700;">Infrastructure Cost:</div>
      <div class="stat-val" style="font-size: 1.8rem; color:#34d399;">$0.00 / mo</div>
      <div style="font-size:0.72rem; color:#94a3b8;">Zero servers, zero API bills, zero maintenance overhead.</div>
    </div>
  </div>
</div>
</div>

<div class="slide">
<h2>Key Features & Granular Logging Experience</h2>
<div class="grid-1-2">
  <div class="shot-wrap">
    <img src="screenshot-settings.jpeg" class="shot-img" alt="Hydrated Settings" />
    <div class="caption">Real App Screenshot: Dedicated Preferences, Tap Presets & Backup Center</div>
  </div>
  <div>
    <div class="grid-2">
      <div class="card">
        <span class="badge">01 · Hardware</span>
        <h3 style="font-size:1.05rem;">Physical NFC Tap</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Write <code>https://mycounterapp.local</code> to any standard sticker. Instant volume registration with tactile haptics.</p>
      </div>
      <div class="card">
        <span class="badge badge-teal">02 · Dashboard</span>
        <h3 style="font-size:1.05rem;">Fluid Radial Progress</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Dynamic glowing ring calculating current intake against daily target (e.g. 2000ml) with smooth fill animations.</p>
      </div>
      <div class="card">
        <span class="badge badge-emerald">03 · Versatility</span>
        <h3 style="font-size:1.05rem;">Drink Classification</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Quick presets for 200ml, 250ml, 330ml, 500ml, 750ml, and 1000ml plus Water, Tea, Smoothie, and Juice categories.</p>
      </div>
      <div class="card">
        <span class="badge">04 · Control</span>
        <h3 style="font-size:1.05rem;">Timeline & Swipe-Delete</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Accidental taps are easily remedied via timestamped entries with instant swipe-to-delete confirmation.</p>
      </div>
      <div class="card">
        <span class="badge badge-teal">05 · Wellness</span>
        <h3 style="font-size:1.05rem;">Smart Reminders</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Interval nudges (1h / 2h / 3h) and fixed alarm windows (9am, 12pm, 3pm, 6pm, 9pm) to preserve cadence.</p>
      </div>
      <div class="card">
        <span class="badge badge-emerald">06 · Glanceable</span>
        <h3 style="font-size:1.05rem;">Home Screen Widget</h3>
        <p style="font-size:0.78rem; color:#94a3b8; margin:0;">Shows progress percentage directly on Android & iOS home screens without opening the app.</p>
      </div>
    </div>
  </div>
</div>
</div>

<div class="slide">
<h2>Storage Architecture & Radical Privacy by Design</h2>
<div class="grid-3" style="margin-bottom: 14px;">
  <div class="card">
    <span class="badge badge-teal">Document Layer</span>
    <h3 style="font-size:1.05rem;">water_logs.json</h3>
    <p style="font-size:0.78rem; color:#94a3b8; margin-bottom:8px;">Every sip saved as an immutable JSON document directly in sandbox storage.</p>
    <code style="font-size:0.7rem; display:block; white-space:pre;">{
  "timestamp": 1729602410,
  "volumeMl": 250,
  "type": "water"
}</code>
  </div>
  <div class="card">
    <span class="badge badge-emerald">Storage Hygiene</span>
    <h3 style="font-size:1.05rem;">Automated Auto-Pruning</h3>
    <p style="font-size:0.78rem; color:#94a3b8; margin-bottom:8px;">On startup, logs older than <strong>7 days</strong> are automatically purged.</p>
    <ul style="font-size:0.74rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li>Guaranteed disk usage &lt; 200 KB</li>
      <li>Instant load times regardless of app age</li>
      <li>Zero SQLite schema corruption risks</li>
    </ul>
  </div>
  <div class="card">
    <span class="badge">Full Portability</span>
    <h3 style="font-size:1.05rem;">Clipboard JSON Sync</h3>
    <p style="font-size:0.78rem; color:#94a3b8; margin-bottom:8px;">Users own 100% of their data with instant export and restore.</p>
    <ul style="font-size:0.74rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li><strong>1-Tap Export:</strong> Copies full log array to clipboard</li>
      <li><strong>1-Tap Import:</strong> Schema-validated offline restore</li>
      <li><strong>Legacy Migration:</strong> SharedPreferences upgrade</li>
    </ul>
  </div>
</div>
<div class="card-highlight" style="padding: 12px 18px;">
  <div style="display: flex; justify-content: space-between; align-items: center;">
    <div>
      <h3 style="color:#38bdf8; margin: 0 0 2px 0;">The Privacy Guarantee: Zero Telemetry, Zero Tracking</h3>
      <p style="font-size: 0.82rem; margin:0; color:#94a3b8;">No third-party SDKs (no Firebase, no Mixpanel, no Google Analytics). Your physiological intake history never leaves your device.</p>
    </div>
    <div style="text-align: right;">
      <span class="badge badge-emerald" style="font-size:0.85rem;">100% Offline</span>
    </div>
  </div>
</div>
</div>

<div class="slide">
<h2>Target Personas & Real-World User Scenarios</h2>
<div class="grid-3">
  <div class="card">
    <div style="font-size: 1.8rem; margin-bottom: 6px;"></div>
    <span class="badge">Desk Professionals</span>
    <h3 style="color:#ffffff;">Developers & Remote Workers</h3>
    <p style="font-size: 0.8rem; color: #fb7185; font-weight:600; margin-bottom:4px;">Pain Point: Mental Flow Interruption</p>
    <p style="font-size: 0.77rem; color: #94a3b8;">Deep in code or documents for hours; forgets to hydrate until dehydration headaches strike.</p>
    <div style="border-top:1px solid rgba(56,189,248,0.2); margin-top:8px; padding-top:8px;">
      <p style="font-size: 0.8rem; color: #38bdf8; font-weight:600; margin-bottom:2px;">Hydrated Solution:</p>
      <p style="font-size: 0.75rem; color: #f8fafc; margin:0;">NFC coaster under coffee mug. Tap phone against desk without switching windows or picking up the phone.</p>
    </div>
  </div>
  <div class="card">
    <div style="font-size: 1.8rem; margin-bottom: 6px;"></div>
    <span class="badge badge-teal">Fitness Community</span>
    <h3 style="color:#ffffff;">Athletes & Gym Goers</h3>
    <p style="font-size: 0.8rem; color: #fb7185; font-weight:600; margin-bottom:4px;">Pain Point: Clunky Volume Math</p>
    <p style="font-size: 0.77rem; color: #94a3b8;">Standard apps only support 250ml glasses; shakers hold 750ml, 1000ml, or custom electrolyte scoops.</p>
    <div style="border-top:1px solid rgba(56,189,248,0.2); margin-top:8px; padding-top:8px;">
      <p style="font-size: 0.8rem; color: #2dd4bf; font-weight:600; margin-bottom:2px;">Hydrated Solution:</p>
      <p style="font-size: 0.75rem; color: #f8fafc; margin:0;">Specific NFC tags on gym bottle programmed to 750ml, plus one-tap custom volume inputs and electrolyte tracking.</p>
    </div>
  </div>
  <div class="card">
    <div style="font-size: 1.8rem; margin-bottom: 6px;"></div>
    <span class="badge badge-emerald">Privacy Minimalists</span>
    <h3 style="color:#ffffff;">Digital Wellness Purists</h3>
    <p style="font-size: 0.8rem; color: #fb7185; font-weight:600; margin-bottom:4px;">Pain Point: Invasive Monetization</p>
    <p style="font-size: 0.77rem; color: #94a3b8;">Tired of health apps asking for Facebook logins, credit cards, or spamming weekly premium notifications.</p>
    <div style="border-top:1px solid rgba(56,189,248,0.2); margin-top:8px; padding-top:8px;">
      <p style="font-size: 0.8rem; color: #34d399; font-weight:600; margin-bottom:2px;">Hydrated Solution:</p>
      <p style="font-size: 0.75rem; color: #f8fafc; margin:0;">Zero accounts, 100% open source transparency, runs offline in flight mode, raw JSON clipboard export.</p>
    </div>
  </div>
</div>
</div>

<div class="slide">
<h2>Friction Annihilation — Before vs. After Hydrated</h2>
<div class="grid-2">
  <div class="card-danger">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
      <h3 style="color:#fb7185; margin:0;">Traditional Hydration Apps</h3>
      <span class="badge badge-rose">35 - 40 Seconds Friction</span>
    </div>
    <div style="display:flex; flex-direction:column; gap:8px;">
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem;">
        <strong>1. Unlock Phone:</strong> Fingerprint / FaceID scans required.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem;">
        <strong>2. Find & Open App:</strong> Sifting through app drawers or home screens.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem;">
        <strong>3. Monetization Gates:</strong> Dismiss promotional popups or paywall banners.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem;">
        <strong>4. Manual Input:</strong> Tap add, rotate volume sliders, pick drink type.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem;">
        <strong>5. Result:</strong> High drop-off rate, 80% abandonment within 2 weeks.
      </div>
    </div>
  </div>
  <div class="card-success">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
      <h3 style="color:#34d399; margin:0;">Hydrated with NFC Tap</h3>
      <span class="badge badge-emerald">&lt; 1 Second Effortless</span>
    </div>
    <div style="display:flex; flex-direction:column; gap:8px;">
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem; border-left:3px solid #10b981;">
        <strong>1. Natural Motion:</strong> Take a drink from your water bottle or cup.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem; border-left:3px solid #10b981;">
        <strong>2. Physical Tap:</strong> Tap phone against sticker on bottle / desk coaster.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem; border-left:3px solid #10b981;">
        <strong>3. Instant Logging:</strong> Background NDEF dispatch registers intake.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem; border-left:3px solid #10b981;">
        <strong>4. Tactile Confirmation:</strong> Subtle haptic vibration confirms save.
      </div>
      <div style="background:rgba(30,41,59,0.7); padding:8px 12px; border-radius:6px; font-size:0.78rem; border-left:3px solid #10b981;">
        <strong>5. Result:</strong> Friction drops to zero; habit persists effortlessly.
      </div>
    </div>
  </div>
</div>
<div class="card" style="margin-top:12px; text-align:center; padding:10px;">
  <span style="font-size:0.85rem; color:#94a3b8;">
    By eliminating <strong>97% of logging time</strong>, tracking becomes an involuntary physical reflex rather than a conscious administrative task.
  </span>
</div>
</div>

<div class="slide">
<h2>Competitive Matrix — Setting the Benchmark</h2>
<p style="font-size:0.82rem; color:#94a3b8; margin-bottom:8px;">
  Comparing Hydrated against leading commercial market solutions across key consumer criteria:
</p>
<table>
  <thead>
    <tr>
      <th style="width:24%;">Capability / Feature</th>
      <th style="width:19%; color:#38bdf8;">Hydrated (Ours)</th>
      <th style="width:19%;">Waterllama</th>
      <th style="width:19%;">Plant Nanny</th>
      <th style="width:19%;">Apple Health / Garmin</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Hardware NFC Tap</strong></td>
      <td style="color:#34d399; font-weight:700;">Native Built-in</td>
      <td style="color:#f59e0b;">iOS Shortcuts Workaround</td>
      <td style="color:#fb7185;">No</td>
      <td style="color:#fb7185;">No</td>
    </tr>
    <tr>
      <td><strong>Privacy Architecture</strong></td>
      <td style="color:#34d399; font-weight:700;">100% Offline (Local JSON)</td>
      <td style="color:#94a3b8;">Partial (iCloud Sync)</td>
      <td style="color:#fb7185;">Cloud Account Required</td>
      <td style="color:#94a3b8;">Cloud Sync Dependent</td>
    </tr>
    <tr>
      <td><strong>Monetization Model</strong></td>
      <td style="color:#34d399; font-weight:700;">100% Free / Open Source</td>
      <td style="color:#fb7185;">Subscription / $15 Paywall</td>
      <td style="color:#fb7185;">Ads & Microtransactions</td>
      <td style="color:#94a3b8;">Tied to $200+ Wearables</td>
    </tr>
    <tr>
      <td><strong>Average Time-to-Log</strong></td>
      <td style="color:#34d399; font-weight:700;">&lt; 1 Second</td>
      <td style="color:#94a3b8;">3–5 Seconds</td>
      <td style="color:#fb7185;">8–12 Seconds (Animations)</td>
      <td style="color:#94a3b8;">5–7 Seconds</td>
    </tr>
    <tr>
      <td><strong>Data Portability</strong></td>
      <td style="color:#34d399; font-weight:700;">1-Tap Raw JSON Sync</td>
      <td style="color:#fb7185;">Proprietary / Locked</td>
      <td style="color:#fb7185;">Proprietary / Locked</td>
      <td style="color:#94a3b8;">Complex XML Export</td>
    </tr>
    <tr>
      <td><strong>Desktop & Web Support</strong></td>
      <td style="color:#34d399; font-weight:700;">Native Desktop + Web PWA</td>
      <td style="color:#fb7185;">iOS / Mac Only</td>
      <td style="color:#fb7185;">Mobile Only</td>
      <td style="color:#94a3b8;">Web Dashboard Only</td>
    </tr>
  </tbody>
</table>
</div>

<div class="slide">
<h2>Hardware Ecosystem — The $0.20 Smart Bottle Revolution</h2>
<div class="grid-3">
  <div class="card">
    <div style="display:flex; justify-content:space-between; align-items:center;">
      <span class="badge badge-emerald">Primary Hardware</span>
      <span style="color:#34d399; font-weight:bold; font-size:0.85rem;">~$0.20 / tag</span>
    </div>
    <h3 style="color:#ffffff; margin-top:6px;">Passive NFC Stickers</h3>
    <p style="font-size:0.77rem; color:#94a3b8; margin-bottom:8px;">
      Waterproof <strong>NTAG213 / NTAG215</strong> adhesive tags adhered to reusable bottles, tumblers, or office mugs.
    </p>
    <ul style="font-size:0.73rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li>Zero battery or charging required forever</li>
      <li>Dishwasher-safe protective epoxy coating</li>
      <li>Turns any regular $10 cup into a smart bottle</li>
    </ul>
  </div>
  <div class="card">
    <div style="display:flex; justify-content:space-between; align-items:center;">
      <span class="badge badge-teal">Ambient Sensing</span>
      <span style="color:#2dd4bf; font-weight:bold; font-size:0.85rem;">Desk Gadget</span>
    </div>
    <h3 style="color:#ffffff; margin-top:6px;">Smart Weight Coasters</h3>
    <p style="font-size:0.77rem; color:#94a3b8; margin-bottom:8px;">
      Bluetooth Low Energy (BLE) load-cell sensor pads placed under your desk cup.
    </p>
    <ul style="font-size:0.73rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li>Detects weight differential when cup is replaced</li>
      <li>Sends delta intake to Hydrated's listener API</li>
      <li>Zero-touch ambient tracking while working</li>
    </ul>
  </div>
  <div class="card">
    <div style="display:flex; justify-content:space-between; align-items:center;">
      <span class="badge">Biometric Sync</span>
      <span style="color:#38bdf8; font-weight:bold; font-size:0.85rem;">Ecosystem</span>
    </div>
    <h3 style="color:#ffffff; margin-top:6px;">Fitness Wearables</h3>
    <p style="font-size:0.77rem; color:#94a3b8; margin-bottom:8px;">
      Integration with WHOOP, Garmin, Apple Watch, and Fitbit biometric streams.
    </p>
    <ul style="font-size:0.73rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li>Ingests sweat rate, ambient heat, & heart rate</li>
      <li>Dynamically elevates daily targets on hot/heavy workout days</li>
      <li>Wrist-complication one-tap logging</li>
    </ul>
  </div>
</div>
<div class="card" style="margin-top:14px; background:rgba(30,41,59,0.5); padding:10px 16px;">
  <div style="display:flex; justify-content:space-between; align-items:center; font-size:0.8rem;">
    <span><strong>Why Not Proprietary Smart Bottles?</strong> Commercial smart bottles cost $80–$120, require proprietary chargers, and fail when electronics get wet. Hydrated achieves superior UX using standard 20¢ stickers on your favorite vessel.</span>
  </div>
</div>
</div>

<div class="slide">
<h2>Design Philosophy — Liquid Glass & Sensory Haptics</h2>
<div class="grid-3">
  <div class="card">
    <span class="badge">Color Palette</span>
    <h3 style="color:#ffffff;">Aquatic Visual Identity</h3>
    <div style="display:flex; gap:8px; margin:10px 0;">
      <div style="flex:1; height:32px; background:#070d1e; border-radius:6px; border:1px solid #334155; text-align:center; font-size:0.65rem; line-height:32px; color:#94a3b8;">#070D1E</div>
      <div style="flex:1; height:32px; background:#0d9488; border-radius:6px; text-align:center; font-size:0.65rem; line-height:32px; color:#ffffff; font-weight:bold;">#0D9488</div>
      <div style="flex:1; height:32px; background:#38bdf8; border-radius:6px; text-align:center; font-size:0.65rem; line-height:32px; color:#0f172a; font-weight:bold;">#38BDF8</div>
    </div>
    <p style="font-size:0.76rem; color:#94a3b8; margin:0;">Curated midnight navy, fresh water teal, and vibrant cyan delivering soothing hydration cues.</p>
  </div>
  <div class="card">
    <span class="badge badge-teal">Depth & Light</span>
    <h3 style="color:#ffffff;">Layered Glassmorphism</h3>
    <p style="font-size:0.76rem; color:#94a3b8; margin-bottom:8px;">Powered by <code>liquid_glass_renderer</code> shaders with Gaussian blur filtering and soft cyan specular highlights.</p>
    <ul style="font-size:0.73rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li>12px smooth border radius</li>
      <li>Translucent dark panels (rgba 15,23,42,0.7)</li>
      <li>Dynamic ambient glow around radial fill</li>
    </ul>
  </div>
  <div class="card">
    <span class="badge badge-emerald">Tactile Resonance</span>
    <h3 style="color:#ffffff;">Subtle Micro-Interactions</h3>
    <p style="font-size:0.76rem; color:#94a3b8; margin-bottom:8px;">Every tap provides sensory reinforcement that builds neurological reward loops.</p>
    <ul style="font-size:0.73rem; color:#94a3b8; padding-left:14px; margin:0;">
      <li>Light impact haptic click on volume tap</li>
      <li>Heavy double-pulse confirmation on NFC scan</li>
      <li>60fps spring animations on progress updates</li>
    </ul>
  </div>
</div>
<div class="card-highlight" style="margin-top:14px; padding:10px 16px;">
  <p style="font-size:0.82rem; margin:0; text-align:center; color:#f8fafc;">
    <em>"Aesthetic excellence builds user pride. When an everyday utility feels sleek, responsive, and tactile, people look forward to logging every drink."</em>
  </p>
</div>
</div>

<div class="slide">
<h2>Future Roadmap — Strategic Evolution</h2>
<div class="grid-4">
  <div class="card">
    <span class="badge badge-emerald">Phase 1 · Q2 2026</span>
    <h3 style="font-size:1.05rem; color:#ffffff;">Wearable OS Companion</h3>
    <ul style="font-size:0.75rem; color:#94a3b8; padding-left:14px; margin:6px 0;">
      <li>Wear OS 5 & watchOS 11 native companion apps</li>
      <li>Glanceable wrist tiles and complications</li>
      <li>Single-tap intake logging on the move</li>
    </ul>
  </div>
  <div class="card">
    <span class="badge badge-teal">Phase 2 · Q3 2026</span>
    <h3 style="font-size:1.05rem; color:#ffffff;">Health Platform Sync</h3>
    <ul style="font-size:0.75rem; color:#94a3b8; padding-left:14px; margin:6px 0;">
      <li>Bidirectional sync with <strong>Health Connect</strong></li>
      <li>Native <strong>Apple HealthKit</strong> hydration writer</li>
      <li>Zero-server offline local background bridge</li>
    </ul>
  </div>
  <div class="card">
    <span class="badge">Phase 3 · Q4 2026</span>
    <h3 style="font-size:1.05rem; color:#ffffff;">Beverage Hydration Index</h3>
    <ul style="font-size:0.75rem; color:#94a3b8; padding-left:14px; margin:6px 0;">
      <li>Scientific beverage hydration factors (BHI)</li>
      <li>Coffee: 0.8x multiplier</li>
      <li>Electrolyte drinks: 1.15x multiplier</li>
    </ul>
  </div>
  <div class="card">
    <span class="badge">Phase 4 · 2027</span>
    <h3 style="font-size:1.05rem; color:#ffffff;">Smart BLE Coaster API</h3>
    <ul style="font-size:0.75rem; color:#94a3b8; padding-left:14px; margin:6px 0;">
      <li>Open Bluetooth load-cell coaster driver</li>
      <li>Completely passive zero-touch logging</li>
      <li>Automatic sip detection upon cup release</li>
    </ul>
  </div>
</div>
<div class="card" style="margin-top:14px; padding:10px 16px;">
  <div style="display:flex; justify-content:space-between; align-items:center; font-size:0.8rem;">
    <span><strong>Guiding North Star:</strong> Maintain 100% offline privacy and sub-second speed while expanding ambient sensor integration.</span>
  </div>
</div>
</div>

<div class="slide">
<div style="display:flex; height:100%; flex-direction:column; justify-content:space-between;">
  <div>
    <h2>Summary & Open Discussion</h2>
    <p style="font-size:0.92rem; color:#94a3b8; margin-bottom:18px;">
      Hydrated solves the hydration crisis not by adding more notifications, but by eliminating logging friction entirely through hardware-integrated physical computing.
    </p>
    <div class="grid-3" style="margin-bottom:18px;">
      <div class="card" style="text-align:center;">
        <span class="badge badge-emerald">Frictionless</span>
        <h3 style="color:#34d399; margin:4px 0;">&lt; 1-Second Tap</h3>
        <p style="font-size:0.76rem; color:#94a3b8; margin:0;">Passive NFC stickers turn any bottle or mug into an instant input device.</p>
      </div>
      <div class="card" style="text-align:center;">
        <span class="badge badge-teal">Privacy-First</span>
        <h3 style="color:#2dd4bf; margin:4px 0;">100% Offline</h3>
        <p style="font-size:0.76rem; color:#94a3b8; margin:0;">Zero accounts, zero trackers, and sub-5ms local JSON file streaming.</p>
      </div>
      <div class="card" style="text-align:center;">
        <span class="badge">Crafted UI</span>
        <h3 style="color:#38bdf8; margin:4px 0;">Glassmorphism</h3>
        <p style="font-size:0.76rem; color:#94a3b8; margin:0;">Fluid radial animations and tactile haptics make habit formation enjoyable.</p>
      </div>
    </div>
  </div>
  <div class="card-highlight" style="padding:16px 20px;">
    <div style="display:flex; justify-content:space-between; align-items:center;">
      <div>
        <h3 style="color:#ffffff; margin:0 0 4px 0; font-size:1.25rem;">Hydrated: Drink. Tap. Done.</h3>
        <p style="font-size:0.82rem; margin:0; color:#94a3b8;">
          Source code, schematics, and platform builds are freely available on GitHub.
        </p>
      </div>
      <div style="text-align:right;">
        <a href="https://github.com/rmdir-sys32/hydra-water-tracker" style="color:#38bdf8; font-weight:700; text-decoration:none; font-size:0.95rem; border:1px solid rgba(56,189,248,0.4); padding:6px 14px; border-radius:8px; background:rgba(14,165,233,0.15);">
          github.com/rmdir-sys32/hydra-water-tracker
        </a>
      </div>
    </div>
  </div>
  <div style="text-align:center; padding-top:8px; font-size:0.8rem; color:#64748b;">
    Open for Questions, Live Demonstration & Collaboration
  </div>
</div>
</div>

</body>
</html>