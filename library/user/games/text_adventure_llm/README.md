# Snow Crash Terminal

> *"The Deliverator belongs to an elite order, a hallowed subcategory..."*

An AI-powered cyberpunk text adventure generator inspired by Neal Stephenson's *Snow Crash*. Uses the Anthropic API (Claude Sonnet) to generate unique Metaverse adventures each time you jack in.

## Requirements

- **Network Connection**: Required to uplink to the Metaverse (Anthropic API)
- **API Key**: Set the `ANTHROPIC_API_KEY` environment variable
- **jq**: JSON processor (install with `opkg install jq` if not present)

## Setup

### Option 1: Create a .env file (recommended)

Copy the example file and add your API key:

```bash
cp .env.example .env
# Edit .env and add your key
```

Your `.env` file should contain:
```
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### Option 2: Export to environment

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

## How to Play

1. Run the payload to initialize your Metaverse uplink
2. Wait while reality renders (~10-30 seconds)
3. Read the scene - you're in the neon-lit world now
4. Navigate using:
   - **▲ UP** - Take the first path
   - **▼ DOWN** - Take the second path
5. Survive 4 decision points to escape the Snow Crash

## The Metaverse Awaits

Each generated adventure features:

- **4 decision steps** with 2 choices each
- **Branching realities** that lead to different fates
- **2 endings**: Hack successful or System crash
- **Snow Crash universe**: Hackers, Kouriers, burbclaves, franchulates, the Raft, and more

```
          [Jack In]
          /       \
       [2A]       [2B]
       /  \       /  \
    [3A]  [3B] [3C]  [3D]
       \    |   |    /
    [HACK OK]  [CRASH]
```

## Features

- **Procedural stories**: Every run generates a unique Metaverse scenario
- **Noir-style prose**: Short, punchy cyberpunk atmosphere
- **Quick sessions**: Full adventure takes 2-3 minutes
- **Haptic feedback**: Feel the victory vibration when you survive

## Technical Details

- **API**: Anthropic Messages API v2023-06-01
- **Model**: Claude Sonnet 4
- **Max tokens**: 2048
- **Timeout**: 60 seconds

## Troubleshooting

### "No Metaverse credentials"
Create a `.env` file with your API key, or export it to your environment.

### "No uplink detected"
Ensure you're connected to a network with internet access.

### "Failed to generate game"
- Verify your API key is valid
- Check network connectivity
- The Metaverse may be temporarily unreachable

### "jq not installed"
Install the codec: `opkg install jq`

### Text display issues
The terminal word-wraps at 40 characters. Some long words may overflow.

## Author

r0yfire

## Version

1.2
