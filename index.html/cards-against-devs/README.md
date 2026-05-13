# 🃏 Cards Against Devs

A real-time multiplayer party game for programmers — built with Supabase Realtime + Anthropic AI.

> *Dark humor. Tech culture. Terrible decisions.*

## Stack

- **Frontend**: Vanilla HTML/CSS/JS — no build step, GitHub Pages ready
- **Realtime multiplayer**: Supabase (Postgres + Realtime subscriptions)
- **AI card generation**: Claude claude-sonnet-4-20250514 via Anthropic API
- **Hosting**: GitHub Pages (free)

## How to Play

1. One player creates a room and shares the code
2. Up to 8 players join
3. Each round: a black "prompt" card appears
4. Players submit white answer cards
5. The rotating judge picks the funniest
6. First to **7 points** wins

---

## Setup Guide

### 1. Clone & Fork

```bash
git clone https://github.com/YOUR_USERNAME/cards-against-devs
cd cards-against-devs
```

### 2. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) → New Project
2. Open **SQL Editor** → paste the contents of `supabase/schema.sql` → Run
3. Go to **Project Settings** → API
4. Copy your **Project URL** and **anon public key**

### 3. Get an Anthropic API Key

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create an API key

> ⚠️ **Security**: Never expose your Anthropic API key in client-side code for production.
> See the [Edge Function section](#securing-the-api-key) below.

### 4. Configure index.html

Open `index.html` and replace the config values:

```js
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';
```

For the Anthropic API key — use the Edge Function approach below (or hardcode for testing only).

### 5. Deploy to GitHub Pages

```bash
git add .
git commit -m "🃏 initial deploy"
git push origin main
```

Then: **GitHub repo → Settings → Pages → Deploy from branch: main**

Your game is live at: `https://YOUR_USERNAME.github.io/cards-against-devs`

---

## Securing the API Key (Production)

Create a Supabase Edge Function to proxy Anthropic calls:

```bash
supabase functions new claude-proxy
```

`supabase/functions/claude-proxy/index.ts`:
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const body = await req.json()
  
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": Deno.env.get("ANTHROPIC_API_KEY")!,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify(body),
  })
  
  const data = await response.json()
  return new Response(JSON.stringify(data), {
    headers: { "Content-Type": "application/json" }
  })
})
```

Deploy it:
```bash
supabase secrets set ANTHROPIC_API_KEY=your_key_here
supabase functions deploy claude-proxy
```

Then update the URL in `index.html`:
```js
const ANTHROPIC_API_URL = 'https://YOUR_PROJECT.supabase.co/functions/v1/claude-proxy';
```

---

## Supabase Realtime Architecture

```
Player A (Host)        Supabase                  Player B, C, D
    │                    │                              │
    ├──create room──────►│                              │
    │                    │◄─────────────join room───────┤
    │                    │                              │
    │◄──────────── realtime subscription ──────────────►│
    │                    │                              │
    ├──start game──►UPDATE rooms.phase='picking'        │
    │                    │──── onRoomUpdate() ─────────►│ (show hand)
    │                    │                              │
    │                    │◄─── INSERT submission ────────┤
    │                    │──── onSubmissionsUpdate() ───►│
    │                    │                              │
    ├─(AI judge)────►UPDATE rooms.phase='reveal'        │
    │                    │──── onRoomUpdate() ─────────►│ (show winner)
```

---

## Customizing the Cards

The AI generates cards dynamically each round. To change the style, edit the prompts in `index.html`:

```js
async function generateBlackCard() {
  // Modify this system prompt to change card style
  const raw = await callClaude(`Your custom prompt here...`, ...);
}
```

---

## License

MIT — go build something cursed.
