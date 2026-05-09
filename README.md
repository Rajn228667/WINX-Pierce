# WINX × Pierce — iOS

> Powered by Pierce Industries

AI-powered accessibility platform for blind and low-vision users. Native SwiftUI iOS app
that runs on your own neural networks via Ollama + Cloudflare Tunnel — your data never
leaves your machine.

## Features

- **AI Companion (Эдит)** — voice-first assistant with a 3D voice-reactive sphere,
  streaming chat, conversational memory, multi-language voice (RU / KK / EN).
- **AI Vision Camera** — real-time object/person detection, distance estimation,
  scene narration via LLaVA.
- **OCR Reader** — high-accuracy text recognition with translation, AI summary
  and large-print fallback.
- **Magnifier** — variable zoom, contrast, inversion, torch.
- **Smart Navigation** — MapKit + step-by-step voice guidance, pharmacy/hospital
  shortcuts, MapKit walking directions.
- **Locator** — directional compass + step counter + altitude for indoor orientation.
- **Walking Mode** — continuous obstacle gauge with haptic danger alerts.
- **Emergency / SOS** — long-press hold-to-trigger, SMS to trusted contact with
  Apple Maps location, one-tap call.
- **WhatsApp / Telegram** voice messages — proper contact picker, voice recording,
  share-sheet integration that respects Apple's URL-scheme rules.
- **Health** — medication reminders, breathing techniques, AI symptom chat.
- **Learning** — voice tutor lessons in your chosen language.
- **Music** — Apple Music control with voice "what's playing?".
- **Diary** — voice journal with on-device speech recognition.
- **Cards** — non-verbal communication phrases.
- **Listen** — real-time transcription for hard-of-hearing users.
- **Currency** — banknote recognition via multimodal AI.
- **Smart Home** — HomeKit lights and scenes.
- **Eye Comfort** — adaptive blue-light filter, contrast, colorblind modes.
- **Voice Control** — full app-wide voice navigation.
- **Accessibility Center** — text size, bold, contrast, language, voice, all live.

## Tech stack

Swift 5.9 · SwiftUI · MVVM · CoreML · Vision · AVFoundation · CoreLocation · MapKit ·
Speech · HomeKit · CoreHaptics · Keychain · CoreMotion · MediaPlayer · Contacts.

## Project layout

```
WINX × Pierce/
├── project.yml                     # XcodeGen project definition
├── Sources/
│   ├── App/                         # @main, RootView, Config
│   ├── Core/                        # Shared managers (Theme, Settings, Voice, ...)
│   ├── Components/                  # Reusable SwiftUI components
│   ├── Features/                    # One folder per feature module
│   └── Resources/                   # Assets.xcassets, Info.plist
└── .github/workflows/build-ios.yml  # CI (macOS runner) → unsigned IPA
```

## Build the IPA

You don't need a Mac. Push to GitHub — CI builds the unsigned IPA for you.

### Option A — GitHub Actions (recommended, no Mac needed)

1. Push the repo to GitHub.
2. Go to **Actions → Build iOS IPA → Run workflow** (or simply push to `main`).
3. Wait \~7 min for the macOS runner.
4. Download `WINXPierce-unsigned-ipa` from the run's **Artifacts**, or from
   **Releases** if you tagged the commit.

### Option B — local Xcode (if you have a Mac)

```bash
brew install xcodegen
xcodegen generate
open WINXPierce.xcodeproj
# In Xcode: Product → Archive → Distribute → Custom → Save .ipa
```

## Sideload onto your iPhone (no Apple Developer account)

The IPA produced by this project is **unsigned** — you sign it with your Apple ID
on your own device using one of:

- **AltStore / SideStore** — pair iPhone with a desktop, install AltServer,
  drop the IPA → AltStore signs and installs. Lasts 7 days per re-signing.
  Free Apple ID. <https://altstore.io>
- **Sideloadly** — desktop app, drag-and-drop IPA, sign with your Apple ID.
  Same 7-day cadence. <https://sideloadly.io>
- **TrollStore** (jailbroken-style permanent install on supported iOS versions
  via developer-certificate exploit). No 7-day refresh required.
  <https://github.com/opa334/TrollStore>

## Configure Ollama

The app talks to your Ollama server through a Cloudflare tunnel. The first launch
will ask you for the tunnel URL and store it securely in the iOS Keychain — you
can change it any time in *Accessibility Center → AI*.

```powershell
# example Windows host script (the one you already use):
ollama serve
ollama run qwen2.5-coder:7b
ollama run llama3.2:3b
cloudflared tunnel --url http://127.0.0.1:11434
# → copy the printed https://*.trycloudflare.com URL into the app
```

Recommended models (already wired up):

- `llama3.2:3b` — fast, used for short answers and voice intents
- `qwen2.5:7b` — chat persona ("Эдит") long answers
- `llava:7b` — multimodal scene description, currency recognition

## Voice quality (premium voices)

iOS ships compact voices by default. To get the natural **Premium** Russian /
English voices: **iOS Settings → Accessibility → Spoken Content → Voices →
\[language\] → tap the voice → download the Premium variant**. The app will
automatically pick the highest-quality voice it finds.

## License

MIT — see [LICENSE](LICENSE).
