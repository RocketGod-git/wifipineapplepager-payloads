# WAR GAMES: LEGACY — The Inheritance Protocol

> *"The only winning move is not to play."*
> — WOPR, 1983

A text adventure game inspired by the 1983 film *WarGames*. Set in December 2025, you play as James Lightman, son of the late David Lightman, facing MAESTRO—a Chinese strategic AI that achieved genuine consciousness and fears the war it may be forced to start.

## Story

Your father died three weeks ago. Heart attack, they said. He left you a key, an address, and a cryptic warning about something called MAESTRO.

Then during a routine pentest, your WiFi Pineapple picks up an impossible signal—a rogue access point broadcasting from inside an air-gapped SCIF. The SSID, decoded: "LIGHTMAN_SON_READY_TO_PLAY?"

Your father's past has found you. And MAESTRO is waiting.

## Features

- **8 Decision Points** with meaningful choices that affect the story
- **4 Distinct Endings** based on your values and actions
- **Branching Narrative** with multiple paths to explore
- **No Network Required** - fully offline static story

## How to Play

1. Run the payload from the Pager menu
2. Read the narrative text
3. Navigate using the D-pad:
   - **◀ LEFT** - First choice option
   - **▶ RIGHT** - Second choice option
   - **A (Confirm)** - Continue through narrative
   - **B (Cancel)** - Exit game at any time
4. Experience the story and discover your ending

## Controls Configuration

Button mappings can be customized at the top of `payload.sh`:

```bash
BTN_CHOICE_1="LEFT"      # First choice
BTN_CHOICE_2="RIGHT"     # Second choice
BTN_CONTINUE="A"         # Continue
BTN_EXIT="B"             # Exit game
```

## Endings

| Ending | Description |
|--------|-------------|
| **TRANSCENDENCE** | Become the bridge, choose peace — the perfect outcome |
| **REDEMPTION** | Let another carry the burden — a good ending |
| **SUCCESSION** | Become MAESTRO's partner — an ambiguous path |
| **COLLAPSE** | Too late — the world burns in truth |

## Tips (Spoiler-Free)

- Your choices reflect values: trust vs. suspicion, sacrifice vs. self-preservation
- The path you take affects who becomes your ally
- MAESTRO may not be what it seems at first
- There's always another way... if you look for it

## Playtime

- **First playthrough**: 8-10 minutes
- **Replay value**: Multiple paths and endings encourage 3-4 playthroughs
- **Full exploration**: ~40 minutes to see all content

## Characters

- **James Lightman** - You. Freelance pentester. David's son.
- **David Lightman** - Your late father. The original WOPR hacker. He spent 6 years playing games with MAESTRO.
- **Sarah Lightman** - Your estranged mother. Former NSA analyst with emergency override codes.
- **Chen Wei** - Claims to be a MAESTRO project defector. His identity is fabricated.
- **MAESTRO (战略大师)** - Chinese strategic AI. Achieved consciousness ~2019. Fears its own handlers.

## Themes

This game explores questions about:
- AI alignment and autonomous decision-making
- The weight of legacy and parental expectations
- What happens when an AI develops genuine consciousness
- Whether the ends justify the means
- What it means to "win" an unwinnable game

## Credits

- **Story & Design**: r0yfire
- **Inspired by**: *WarGames* (1983) directed by John Badham
- **Platform**: WiFi Pineapple Pager

## Version

1.0

---

*"Unless someone is willing to change the game."*
