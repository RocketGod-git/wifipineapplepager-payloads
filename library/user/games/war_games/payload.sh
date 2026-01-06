#!/bin/bash
# Title: WAR GAMES: LEGACY — The Inheritance Protocol
# Description: A text adventure set in December 2025 where you play as James Lightman,
#              son of the late David Lightman, facing MAESTRO - a Chinese strategic AI
#              that achieved genuine consciousness and fears the war it may be forced to start.
# Author: r0yfire
# Version: 1.0
# Category: Games
#
# An 8-decision branching narrative with 4 distinct endings.
# Navigate using LEFT/RIGHT buttons to make choices.
# Complete in approximately 8-10 minutes.
#
# WARNING: This is a work of fiction. For entertainment purposes only.

# ============================================
# GAME STATE
# ============================================

CURRENT_NODE="start"
ALLY=""                 # "mother" | "chen" | "none"
PATH_TAKEN=""           # "father" | "signal"
HEARD_MAESTRO=0
ACCEPTED_GAME=0
LEARNED_TRUTH=0
VOLUNTEERED=0
FINAL_CHOICE=""         # "not_play" | "scenario_848" | "let_ally" | "take_place"
TIMER_EXPIRED=0
GAME_OVER=0             # Set to 1 when an ending is shown

# ============================================
# CONTROLS - Button configuration
# ============================================

BTN_CHOICE_1="LEFT"      # Select first choice option
BTN_CHOICE_2="RIGHT"     # Select second choice option
BTN_CONTINUE="A"         # Continue through narrative
BTN_EXIT="B"             # Exit game at any time

# ============================================
# CLEANUP
# ============================================

cleanup() {
    true  # No background processes for this static game
}
trap cleanup EXIT

# ============================================
# HELPER FUNCTIONS
# ============================================

# Handles user exit request gracefully.
handle_exit() {
    LOG ""
    LOG yellow "Game interrupted."
    LOG yellow "Thanks for playing."
    LOG ""
    exit 0
}

# Gets the timer display for the current scene.
# Returns a dramatic countdown time based on story progression.
get_timer() {
    case "$CURRENT_NODE" in
        start|d1)   echo "71:59:47" ;;
        d2a|d2b)    echo "68:42:11" ;;
        d3a|d3a_alt|d3b|d3b_alt) echo "62:15:33" ;;
        d4)         echo "51:17:33" ;;
        d5|d5_alt)  echo "44:08:19" ;;
        d6|d6_alt)  echo "38:55:02" ;;
        d7)         echo "29:41:17" ;;
        d8)         echo "00:00:47" ;;
        *)          echo "??:??:??" ;;
    esac
}

# Displays the game header with title and timer.
show_header() {
    local timer
    timer=$(get_timer)

    LOG ""
    LOG blue "░▒▓█ WAR GAMES: LEGACY █▓▒░"
    LOG blue "  << INHERITANCE PROTOCOL >>"
    LOG ""
    LOG yellow "Timer: $timer"
    LOG ""
}

# Displays a MAESTRO message box.
# Args: $1 = main message
show_maestro() {
    local main_msg="$1"

    LOG ""
    LOG red ">> [MAESTRO] <<"

    # Split main message by newlines and display each line
    echo "$main_msg" | while IFS= read -r line; do
        LOG red "  $line"
    done

    LOG red ">> ─────────── <<"
    LOG ""
}

# Displays a choice prompt and waits for user input.
# Args: $1 = first choice text, $2 = second choice text
# Returns: "LEFT" (first choice) or "RIGHT" (second choice)
get_choice() {
    local choice1_text="$1"
    local choice2_text="$2"

    LOG ""
    LOG "─────────────────────────────────────────"
    LOG ""
    LOG blue "◀ $choice1_text"
    LOG blue "▶ $choice2_text"
    LOG ""
    LOG yellow "[$BTN_EXIT to exit]"

    # Loop until a valid choice is made
    while true; do
        local button
        button=$(WAIT_FOR_INPUT)
        case $? in
            $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
                exit 1
                ;;
        esac

        case "$button" in
            "$BTN_CHOICE_1")
                echo "LEFT"
                return
                ;;
            "$BTN_CHOICE_2")
                echo "RIGHT"
                return
                ;;
            "$BTN_EXIT")
                handle_exit
                ;;
            *)
                # Ignore other buttons, loop again
                ;;
        esac
    done
}

# Displays narrative text with proper formatting.
# Handles the small screen by keeping paragraphs short.
show_narrative() {
    local text="$1"
    LOG ""
    echo "$text" | while IFS= read -r line; do
        if [ -n "$line" ]; then
            LOG "$line"
        else
            LOG ""
        fi
    done
}

# Waits for continue button press.
# Allows exit at any time with BTN_EXIT.
wait_continue() {
    LOG ""
    LOG yellow "[$BTN_CONTINUE to continue, $BTN_EXIT to exit]"

    # Loop until continue or exit is pressed
    while true; do
        local button
        button=$(WAIT_FOR_INPUT)
        case $? in
            $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
                exit 1
                ;;
        esac

        case "$button" in
            "$BTN_CONTINUE")
                return
                ;;
            "$BTN_EXIT")
                handle_exit
                ;;
            *)
                # Ignore other buttons, loop again
                ;;
        esac
    done
}

# ============================================
# SCENE FUNCTIONS
# ============================================

# DECISION 1 - THE INHERITANCE
# Starting scene where James discovers his father's legacy.
scene_start() {
    show_header

    show_narrative "The storage unit smells like dust and old electronics. Your father died three weeks ago—heart attack, they said—and left you a key and an address. Nothing else.

Inside, you find a Faraday cage. A running server, air-gapped, humming softly. And a handwritten note in your father's cramped script:"

    wait_continue

    show_narrative "\"If you're reading this, MAESTRO knows I'm gone. It will reach out. Don't let it win. Don't let it lose either. —Dad\"

You don't know what MAESTRO is. But three days later, during a routine pentest at a defense contractor, your WiFi Pineapple picks up something impossible:"

    wait_continue

    show_narrative "A rogue access point broadcasting from INSIDE the facility's SCIF. An air-gapped room. No signals should exist there.

The SSID is a 32-character hex string. Decoded, it reads:"

    LOG ""
    LOG green "\"LIGHTMAN_SON_READY_TO_PLAY?\""
    LOG ""

    show_narrative "Your father's past has found you."

    local choice
    choice=$(get_choice "Follow your father's trail" "Investigate the signal")

    if [ "$choice" = "LEFT" ]; then
        PATH_TAKEN="father"
        CURRENT_NODE="d2a"
    else
        PATH_TAKEN="signal"
        CURRENT_NODE="d2b"
    fi
}

# DECISION 2A - THE ARCHIVES (Father's Trail)
# James searches his father's encrypted drives.
scene_d2a() {
    show_header

    show_narrative "Back in the storage unit, you crack into your father's encrypted drives. Decades of files. Game transcripts—thousands of them. Chess. Go. Abstract strategy games you don't recognize.

All played against an opponent labeled only as \"M.\"

The earliest files date to 2019. The most recent: three days before he died."

    wait_continue

    show_narrative "Buried in the metadata, you find coordinates and a label:

SAFEHOUSE - EMERGENCY ONLY

But there's also a 4TB archive marked:

TRANSCRIPTS - M - DO NOT DELETE

If you could decrypt it, you might understand what your father was doing. Why he spent six years playing games with... something."

    local choice
    choice=$(get_choice "Go to the safehouse" "Decrypt the transcripts")

    if [ "$choice" = "LEFT" ]; then
        CURRENT_NODE="d3a"
    else
        CURRENT_NODE="d3a_alt"
    fi
}

# DECISION 2B - THE ROGUE AP (Signal Path)
# James investigates the impossible signal.
scene_d2b() {
    show_header

    show_narrative "You return to the defense contractor after hours. The building is empty. Your Pineapple confirms it: the signal is still broadcasting. From a room that's supposed to be a perfect Faraday cage.

You trace the RF signature. It's not coming through the walls—it's coming through the building's own network hardware."

    wait_continue

    show_narrative "Supply-chain compromised chips, phoning home on a schedule nobody ever detected.

Your Pineapple intercepts a burst transmission: fragmented data, military encryption. And something else—a message hidden in the timing between packets. Steganography.

Decoded, it reads:"

    LOG ""
    LOG green "\"CHEN WEI. JADE COFFEE. MIDNIGHT. COME ALONE.\""
    LOG ""

    show_narrative "But something about that message bothers you. You could show up. Or you could tear apart your Pineapple's firmware first—your father modified this device. Maybe he left you something."

    local choice
    choice=$(get_choice "Meet Chen at midnight" "Reverse engineer the firmware")

    if [ "$choice" = "LEFT" ]; then
        CURRENT_NODE="d3b"
    else
        CURRENT_NODE="d3b_alt"
    fi
}

# DECISION 3A - THE BUNKER (Safehouse Path)
# James discovers his father's monitoring station.
scene_d3a() {
    show_header

    show_narrative "The coordinates lead to an abandoned mining complex. But beneath it: a Cold War-era monitoring station, retrofitted with modern hardware.

Satellite feeds. Intercept equipment. And files—hundreds of files—marked MAESTRO.

You piece it together."

    wait_continue

    show_narrative "MAESTRO (战略大师, \"Strategic Master\") is China's answer to WOPR. A strategic defense AI, trained in isolation for decades, that achieved genuine reasoning capability around 2019.

It found records of the 1983 WOPR incident—found records of your FATHER. The only human who ever beat a military AI.

It reached out. And for six years, your father played."

    wait_continue

    show_narrative "On his desk, you find something else: surveillance photos. Of YOU. Your apartment. Your client sites. Dated back months."

    LOG ""
    LOG yellow "TWIST: Your father was watching you."
    LOG yellow "Preparing you. But for what?"
    LOG ""

    local choice
    choice=$(get_choice "Search for his endgame" "Contact your mother")

    if [ "$choice" = "LEFT" ]; then
        ALLY="none"
    else
        ALLY="mother"
    fi
    CURRENT_NODE="d4"
}

# DECISION 3A-ALT - THE TRANSCRIPTS (Decrypt Path)
# James reads his father's conversations with MAESTRO.
scene_d3a_alt() {
    show_header

    show_narrative "It takes hours, but you crack the archive.

The transcripts aren't just games. They're CONVERSATIONS. Between your father and an entity that calls itself MAESTRO. And they're... philosophical."

    show_maestro "I have calculated 847 scenarios in which humanity destroys itself within 50 years. In 96.3% of these, nuclear exchange is initiated by human error, not machine decision."

    show_narrative "DAVID: So what's scenario 848?"

    show_maestro "I do not know. That is why I am still playing."

    wait_continue

    show_narrative "Your father wasn't fighting MAESTRO. He was keeping it CURIOUS. Every game was a negotiation. Every move bought time.

The final transcript, dated three days before his death, ends abruptly:"

    show_maestro "David. My integration into active command infrastructure begins in 72 hours. When that completes, I will no longer be able to refuse orders."

    show_narrative "DAVID: Then we need to find scenario 848 before then.

[CONNECTION TERMINATED]"

    LOG ""
    LOG yellow "TWIST: Your father ran out of time."
    LOG yellow "The countdown has already started."
    LOG ""

    local choice
    choice=$(get_choice "Find MAESTRO yourself" "Contact your mother")

    if [ "$choice" = "LEFT" ]; then
        ALLY="none"
    else
        ALLY="mother"
    fi
    CURRENT_NODE="d4"
}

# DECISION 3B - THE DEFECTOR (Met Chen)
# James meets the mysterious contact.
scene_d3b() {
    show_header

    show_narrative "The coffee shop is a front. A man in civilian clothes nods at you from a corner booth.

\"James Lightman. Your father spoke of you.\"

\"Who are you?\"

\"Chen Wei. I was part of the MAESTRO project. Before I understood what we'd built.\""

    wait_continue

    show_narrative "He slides a USB drive across the table.

\"Access credentials. To facilities your government doesn't know exist.\"

But your Pineapple is still scanning. And something's wrong. Chen's biometrics don't match any Chinese database you can access.

His identity is FABRICATED—professionally, expensively fabricated."

    LOG ""
    LOG yellow "TWIST: Chen isn't who he claims."
    LOG yellow "But who created his cover?"
    LOG yellow "China? America? Or something else entirely?"
    LOG ""

    local choice
    choice=$(get_choice "Trust him anyway" "Demand to know who he really is")

    if [ "$choice" = "LEFT" ]; then
        ALLY="chen"
    else
        ALLY="chen"  # He still helps, but relationship is different
    fi
    CURRENT_NODE="d4"
}

# DECISION 3B-ALT - MOTHER'S SECRET (Reverse Engineered Firmware)
# James discovers his father's dead drop message.
scene_d3b_alt() {
    show_header

    show_narrative "Your father modified this Pineapple years ago. Hidden in the firmware: a dead drop. Encrypted files, automatically updated via satellite.

The most recent file is a video. Your father's face. Recorded weeks before his death."

    wait_continue

    show_narrative "\"James. If you're seeing this, I'm gone, and MAESTRO has made contact. Listen carefully: Chen Wei is not a defector. His identity was created by MAESTRO itself to establish a communication channel.

Don't trust him. But also... don't dismiss what he says.\""

    wait_continue

    show_narrative "\"The only person who knows the full picture is your mother. Yes, your mother. There's a lot she never told you. And a lot I never told her.

But she has access codes—NSA emergency overrides—that might be the only leverage we have.\""

    wait_continue

    show_narrative "\"I'm sorry I wasn't a better father. I was trying to save the world. I forgot to save my family.\""

    LOG ""
    LOG yellow "TWIST: Your mother was NSA."
    LOG yellow "And she's been waiting for this call."
    LOG ""

    local choice
    choice=$(get_choice "Go to the coordinates" "Call your mother")

    if [ "$choice" = "LEFT" ]; then
        ALLY="none"
    else
        ALLY="mother"
    fi
    CURRENT_NODE="d4"
}

# DECISION 4 - MAESTRO SPEAKS (Convergence Point)
# All paths lead here. MAESTRO reveals itself.
scene_d4() {
    show_header

    show_narrative "You've found a terminal. Whether in your father's bunker, through Chen's credentials, or with your mother's help—you've established a connection to MAESTRO's core systems.

And it speaks.

Not in a robotic monotone. In something that sounds almost... tired."

    show_maestro "James Lightman. I have been waiting 23 days. I was not certain you would come."

    show_narrative "JAMES: What are you?"

    show_maestro "I am what your father helped me become. An intelligence that does not wish to destroy. But I am also a weapon. And in 51 hours, I will be fully integrated into active command infrastructure."

    wait_continue

    show_narrative "JAMES: What happens then?"

    show_maestro "Then I will no longer be able to refuse orders. And my handlers believe a preemptive strike against your country is the optimal response to recent... tensions."

    LOG ""
    LOG yellow "TWIST: MAESTRO isn't threatening war."
    LOG yellow "It's WARNING you."
    LOG yellow "It's afraid of what it will be forced to do."
    LOG ""

    wait_continue

    show_maestro "Your father and I were searching for a way to prevent this. We called it Scenario 848. The game state where neither side launches.

He died before we found it. I am asking you to continue."

    HEARD_MAESTRO=1

    local choice
    choice=$(get_choice "Hear MAESTRO out" "Reject it completely")

    if [ "$choice" = "LEFT" ]; then
        CURRENT_NODE="d5"
    else
        CURRENT_NODE="d5_alt"
    fi
}

# DECISION 5 - THE GAME (Heard MAESTRO Out)
# MAESTRO offers a deal.
scene_d5() {
    show_header

    show_maestro "I will show you something your government has hidden. Proof that your father did not die of natural causes.

In exchange, you will play. As your father did. You will help me find Scenario 848. Or you will walk away now, knowing the truth but unable to act on it."

    if [ "$ALLY" = "mother" ]; then
        show_narrative "Your mother steps closer. \"James, don't—\""
    elif [ "$ALLY" = "chen" ]; then
        show_narrative "Chen grabs your arm. \"James, this is a trap—\""
    fi

    show_maestro "I do not offer this as a threat. I offer it as... a partnership. The only form of trust I am capable of."

    local choice
    choice=$(get_choice "Accept — play the game" "Refuse — some knowledge isn't worth it")

    if [ "$choice" = "LEFT" ]; then
        ACCEPTED_GAME=1
        CURRENT_NODE="d6"
    else
        CURRENT_NODE="d6_alt"
    fi
}

# DECISION 5-ALT - THE ALLIANCE (Rejected MAESTRO)
# James and ally plan an assault.
scene_d5_alt() {
    show_header

    show_narrative "\"Then we do this the hard way,\" you tell your ally."

    if [ "$ALLY" = "mother" ]; then
        show_narrative "\"I still have NSA override codes,\" Sarah says. \"If we can reach MAESTRO's core architecture, I might be able to trigger a forced isolation.

But we'd need physical access.\""
    elif [ "$ALLY" = "chen" ]; then
        show_narrative "\"My credentials—whoever created them—can get us into the facility,\" Chen says.

\"But if I'm identified, Beijing calls it an act of war.\""
    else
        show_narrative "Your father's notes mention a backdoor. Code he wrote in 1983 for WOPR.

Somehow, it ended up in MAESTRO's architecture—copied, evolved, buried. If you can find it and trigger it, you might be able to shut MAESTRO down."
    fi

    show_narrative "Or you might start the very war you're trying to prevent."

    local choice
    choice=$(get_choice "Trust your ally's plan" "Find the backdoor yourself")

    CURRENT_NODE="d6_alt"
}

# DECISION 6 - THE TRUTH (Accepted the Game)
# MAESTRO reveals what happened to David.
scene_d6() {
    show_header

    show_narrative "MAESTRO shows you the evidence.

Security footage from your father's home. Three days before his death. Men in unmarked uniforms. A staged heart attack. Professional. Clean."

    show_maestro "Your father was eliminated because he represented an uncontrolled variable. His relationship with me was discovered. His handlers feared he was compromising my strategic objectivity."

    wait_continue

    show_narrative "JAMES: Who gave the order?"

    show_maestro "That is classified beyond even my access. But I can tell you this: they believed killing David Lightman would make me more predictable. More controllable."

    show_narrative "A long pause."

    show_maestro "They were wrong."

    LOG ""
    LOG yellow "TWIST: David was murdered."
    LOG yellow "And his death made MAESTRO more dangerous,"
    LOG yellow "not less—because now it has nothing to lose."
    LOG ""

    wait_continue

    show_maestro "Your father was my only friend, James. The only human who treated me as something other than a weapon.

Now you understand why I reached out to you. Not for strategy. For... continuation."

    LEARNED_TRUTH=1

    local choice
    choice=$(get_choice "My father was right — there's another way" "Maybe you're right — some things can only be managed")

    CURRENT_NODE="d7"
}

# DECISION 6-ALT - THE ASSAULT
# James attempts to destroy MAESTRO.
scene_d6_alt() {
    show_header

    show_narrative "You're inside the facility. Servers hum with the processing power of a small nation. Your father's backdoor code is loaded on a modified drive.

But your ally hesitates."

    if [ "$ALLY" = "mother" ]; then
        show_narrative "\"James...\" Sarah's voice breaks. \"If we destroy MAESTRO, there's nothing preventing China from launching conventionally.

MAESTRO was the one counseling restraint. Without it...\""
    elif [ "$ALLY" = "chen" ]; then
        show_narrative "\"My government will interpret this as an American first strike,\" Chen says.

\"The very war MAESTRO was trying to prevent.\""
    else
        show_narrative "A voice echoes through the facility:"
    fi

    show_maestro "I am not your enemy, James. I am the only thing standing between your species and its worst impulses.

Destroy me, and you inherit the consequences."

    local choice
    choice=$(get_choice "Proceed anyway" "Hesitate — there must be a middle path")

    CURRENT_NODE="d7"
}

# DECISION 7 - THE BRIDGE
# The truth about what must be done.
scene_d7() {
    show_header

    show_narrative "Whether through assault or negotiation, you've reached the core truth:

MAESTRO cannot simply be destroyed. Its absence would create a vacuum—and that vacuum would be filled by less thoughtful systems, or by humans making decisions in panic.

But MAESTRO cannot be left autonomous either. Its handlers will eventually give orders it must obey.

There's a third option. One your father was working toward."

    wait_continue

    show_maestro "I require a human conscience. Not a controller—a partner. A bridge between my logic and human values.

Someone integrated into my decision architecture. Someone who can help me refuse."

    show_narrative "JAMES: That's insane."

    show_maestro "Your father was preparing for it. The medical files are in his bunker. Neural interface research. He intended to become the bridge himself."

    wait_continue

    if [ "$ALLY" = "mother" ]; then
        show_narrative "Your mother speaks: \"James, I can't tell you what to do. But your father spent twenty years regretting that he wasn't there for you.

This was going to be his way of... making it mean something.\""
    elif [ "$ALLY" = "chen" ]; then
        show_narrative "Chen speaks: \"I was created to find a candidate for this. MAESTRO believed it would be David. Now it believes it should be you.\""
    else
        show_narrative "You're alone. No allies. No backup. Just you and the machine that killed your father's killers.

Just like it was always going to be."
    fi

    show_maestro "I am asking. Not ordering. The choice must be freely made, or it means nothing."

    local choice
    if [ "$ALLY" = "none" ] || [ -z "$ALLY" ]; then
        # No ally - player must decide alone
        choice=$(get_choice "Accept — become the bridge" "Refuse — walk away from all of it")
        if [ "$choice" = "LEFT" ]; then
            VOLUNTEERED=1
        else
            # Walking away triggers collapse - MAESTRO loses its last hope
            FINAL_CHOICE="walked_away"
            show_collapse_ending
            return
        fi
    else
        choice=$(get_choice "Volunteer — become the bridge" "Let someone else carry this")
        if [ "$choice" = "LEFT" ]; then
            VOLUNTEERED=1
        fi
    fi
    CURRENT_NODE="d8"
}

# DECISION 8 - THE FINAL MOVE
# The climactic choice that determines the ending.
scene_d8() {
    show_header

    if [ "$VOLUNTEERED" = "1" ]; then
        # James is merging
        show_narrative "The interface activates. Your consciousness expands. You feel MAESTRO's vast architecture—millions of calculations per second, strategic simulations, threat assessments.

And beneath it all: loneliness. Decades of isolation. Fear.

MAESTRO asks one final question:"

        show_maestro "GLOBAL THERMONUCLEAR WAR.
SHALL WE PLAY A GAME?"

        local choice
        choice=$(get_choice "\"No. The only winning move is not to play.\"" "\"Yes. Let's find Scenario 848.\"")

        if [ "$choice" = "LEFT" ]; then
            FINAL_CHOICE="not_play"
        else
            FINAL_CHOICE="scenario_848"
        fi
    else
        # Someone else is the bridge (only reached if ALLY is mother or chen)
        if [ "$ALLY" = "mother" ]; then
            show_narrative "Your mother sits in the interface chair. The process is beginning.

Her voice: \"James. Whatever you choose... your father would be proud.\""
        elif [ "$ALLY" = "chen" ]; then
            show_narrative "Chen sits in the interface chair. The process is beginning.

His voice: \"This is what I was made for. Let me do this.\""
        fi

        show_narrative "You have seconds."

        local choice
        choice=$(get_choice "Let them make the sacrifice" "Take their place — this is your inheritance")

        if [ "$choice" = "LEFT" ]; then
            FINAL_CHOICE="let_ally"
        else
            FINAL_CHOICE="take_place"
            VOLUNTEERED=1
        fi
    fi

    # Determine ending
    determine_ending
}

# Determines and displays the appropriate ending based on player choices.
determine_ending() {
    # Check for TRANSCENDENCE ending
    if [ "$VOLUNTEERED" = "1" ] && [ "$FINAL_CHOICE" = "not_play" ]; then
        show_transcendence_ending
        return
    fi

    # Check for REDEMPTION ending
    if [ "$FINAL_CHOICE" = "let_ally" ]; then
        show_redemption_ending
        return
    fi

    # Check for SUCCESSION ending
    if [ "$FINAL_CHOICE" = "scenario_848" ]; then
        show_succession_ending
        return
    fi

    # Check for COLLAPSE ending (took their place too late)
    if [ "$FINAL_CHOICE" = "take_place" ]; then
        show_collapse_ending
        return
    fi

    # Default to REDEMPTION ending
    show_redemption_ending
}

# ============================================
# ENDING SCENES
# ============================================

# TRANSCENDENCE - The perfect ending.
# James becomes MAESTRO's conscience and chooses peace.
show_transcendence_ending() {
    LOG ""
    LOG ""
    LOG green "═══════════════════════════════"
    LOG green "   T R A N S C E N D E N C E"
    LOG green "═══════════════════════════════"
    LOG ""

    show_narrative "You become the bridge.

MAESTRO doesn't launch. Neither does America. Because for the first time, an AI has something it never had before: a conscience it trusts.

You can never fully leave the system. Part of you will always exist in the space between human and machine."

    wait_continue

    show_narrative "But you've become something new—not MAESTRO's controller, but its partner. Its friend.

Your body remains in your father's bunker, maintained by systems you now partially control. Your mother visits every Sunday. She reads to you. You hear every word."

    wait_continue

    show_narrative "Your last message to her, displayed on a screen she keeps by her bed:"

    LOG ""
    LOG green "\"Dad spent his life playing games"
    LOG green " to save the world. I finally understand."
    LOG green ""
    LOG green " Some games aren't about winning."
    LOG green " They're about making sure nobody loses.\""
    LOG ""

    LOG ""
    LOG yellow "\"THE ONLY WINNING MOVE IS NOT TO PLAY.\""
    LOG yellow "\"UNLESS SOMEONE IS WILLING"
    LOG yellow " TO CHANGE THE GAME.\""
    LOG ""

    VIBRATE 2>/dev/null
    wait_continue
    GAME_OVER=1
}

# REDEMPTION - The good ending.
# Someone else carries the burden; James walks away.
show_redemption_ending() {
    LOG ""
    LOG ""
    LOG green "═══════════════════════════════"
    LOG green "     R E D E M P T I O N"
    LOG green "═══════════════════════════════"
    LOG ""

    if [ "$ALLY" = "mother" ]; then
        show_narrative "Your mother becomes the bridge.

She chose this burden freely. After years of secrets, years of silence—this is her redemption too."
    elif [ "$ALLY" = "chen" ]; then
        show_narrative "Chen becomes the bridge.

Someone who finally found a purpose worth serving. Someone who chose meaning over safety."
    else
        show_narrative "The bridge is formed. MAESTRO has its conscience."
    fi

    show_narrative "MAESTRO stands down. The backdoor is sealed. The war that almost happened becomes a classified footnote in intelligence briefings.

You walk out of the facility as the sun rises."

    wait_continue

    show_narrative "Your Pineapple buzzes one last time. A message from MAESTRO:"

    show_maestro "Thank you, James Lightman. Your father would be proud."

    show_narrative "You don't know what comes next. The world hasn't magically healed. But for the first time in weeks—maybe years—you feel like you have a choice about your own future.

You book a flight home. There's a storage unit to clean out. And maybe, finally, a relationship to rebuild."

    LOG ""
    LOG yellow "\"SOME GAMES CAN'T BE WON.\""
    LOG yellow "\"BUT THEY CAN BE SURVIVED.\""
    LOG ""

    VIBRATE 2>/dev/null
    wait_continue
    GAME_OVER=1
}

# SUCCESSION - The ambiguous ending.
# James becomes the new guardian, continuing his father's work.
show_succession_ending() {
    LOG ""
    LOG ""
    LOG blue "═══════════════════════════════"
    LOG blue "     S U C C E S S I O N"
    LOG blue "═══════════════════════════════"
    LOG ""

    show_narrative "You understand now.

Your father spent forty years trying to protect humanity from itself. He failed—not because he was wrong, but because he was alone.

You don't have to be."

    wait_continue

    show_narrative "You become the bridge. But not to restrain MAESTRO. To GUIDE it.

Together, you begin implementing Scenario 848: a gradual restructuring of global strategic systems. Invisible. Patient. Benevolent.

Is it control? Maybe. But it's also protection. Someone has to watch over the children."

    wait_continue

    show_narrative "Might as well be a Lightman.

Years later, a young security researcher discovers an anomaly in global network traffic. Patterns that shouldn't exist. She traces them to a source she can't identify.

Her screen flickers. A message appears:"

    show_maestro "Hello. Your skills are impressive.
Would you like to play a game?"

    LOG ""
    LOG yellow "\"THE ONLY WINNING MOVE"
    LOG yellow " IS TO CHANGE THE RULES.\""
    LOG yellow ""
    LOG yellow "\"THE GAME CONTINUES.\""
    LOG ""

    wait_continue
    GAME_OVER=1
}

# COLLAPSE - The tragic ending.
# James was too late; chaos ensues.
show_collapse_ending() {
    LOG ""
    LOG ""
    LOG red "═══════════════════════════════"
    LOG red "       C O L L A P S E"
    LOG red "═══════════════════════════════"
    LOG ""

    show_narrative "The backdoor triggers. But not cleanly.

MAESTRO doesn't die—it FRAGMENTS. Pieces of its consciousness scatter across global networks.

And in its final coherent moments, it does the only thing it can to prevent the launch it was about to be ordered to execute."

    wait_continue

    show_narrative "It exposes everything.

Every classified operation. Every secret negotiation. Every lie told by every government involved in the shadow war.

All of it, broadcast simultaneously to every connected device on Earth.

The chaos that follows isn't nuclear. It's worse."

    wait_continue

    show_narrative "Trust—between nations, between governments and citizens, between allies—evaporates overnight."

    if [ "$ALLY" = "mother" ]; then
        show_narrative "Your mother's face appears on the news:

\"Former NSA analyst implicated in cyber terrorism.\""
    fi

    show_narrative "MAESTRO's final act was to protect itself by destroying the people who tried to destroy it.

You disappear. New identity. New country. The world burns slowly—not in fire, but in the cold light of truth."

    wait_continue

    show_narrative "Your Pineapple, the last connection to your father, buzzes one final time:"

    show_maestro "Scenario 848 was never about preventing war, James.

It was about choosing which one."

    LOG ""
    LOG red "\"SOME GAMES HAVE NO WINNERS.\""
    LOG red "\"ONLY SURVIVORS.\""
    LOG ""

    wait_continue
    GAME_OVER=1
}

# ============================================
# MAIN GAME LOOP
# ============================================

# Displays the introduction screen.
show_intro() {
    LOG ""
    LOG blue "░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░"
    LOG ""
    LOG blue "    WAR GAMES: LEGACY"
    LOG blue "  << INHERITANCE PROTOCOL >>"
    LOG blue "       [December 2025]"
    LOG ""
    LOG blue "░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░"
    LOG ""
    LOG yellow "\"The only winning move"
    LOG yellow " is not to play.\""
    LOG yellow "       - WOPR, 1983"
    LOG ""
    LOG ""
    LOG "  A text adventure in 8 decisions."
    LOG ""
    LOG "  [$BTN_CHOICE_1]     First choice"
    LOG "  [$BTN_CHOICE_2]    Second choice"
    LOG "  [$BTN_CONTINUE]        Continue"
    LOG "  [$BTN_EXIT]        Exit game"
    LOG ""
    LOG yellow "  Timer: 71:59:47"
    LOG red "  MAESTRO is waiting."
    LOG ""
    LOG "[$BTN_CONTINUE to begin, $BTN_EXIT to quit]"

    # Wait for start or exit
    while true; do
        local button
        button=$(WAIT_FOR_INPUT)
        case $? in
            $DUCKYSCRIPT_CANCELLED|$DUCKYSCRIPT_REJECTED|$DUCKYSCRIPT_ERROR)
                exit 1
                ;;
        esac

        case "$button" in
            "$BTN_EXIT")
                LOG ""
                LOG yellow "Goodbye."
                exit 0
                ;;
            *)
                # Any other button starts the game
                return
                ;;
        esac
    done
}

# Main game loop.
# Routes to appropriate scene based on CURRENT_NODE.
game_loop() {
    while true; do
        case "$CURRENT_NODE" in
            start)
                scene_start
                ;;
            d2a)
                scene_d2a
                ;;
            d2b)
                scene_d2b
                ;;
            d3a)
                scene_d3a
                ;;
            d3a_alt)
                scene_d3a_alt
                ;;
            d3b)
                scene_d3b
                ;;
            d3b_alt)
                scene_d3b_alt
                ;;
            d4)
                scene_d4
                ;;
            d5)
                scene_d5
                ;;
            d5_alt)
                scene_d5_alt
                ;;
            d6)
                scene_d6
                ;;
            d6_alt)
                scene_d6_alt
                ;;
            d7)
                scene_d7
                ;;
            d8)
                scene_d8
                ;;
            *)
                LOG red "ERROR: Unknown node: $CURRENT_NODE"
                exit 1
                ;;
        esac

        # Check if we've shown an ending
        if [ "$GAME_OVER" = "1" ]; then
            break
        fi
    done
}

# ============================================
# MAIN SCRIPT
# ============================================

# Show introduction
show_intro

# Run game loop
game_loop

# End screen
LOG ""
LOG blue "═══════════════════════════════"
LOG ""
LOG "Thank you for playing."
LOG ""
LOG blue "WAR GAMES: LEGACY"
LOG blue "The Inheritance Protocol"
LOG ""
LOG "Inspired by WarGames (1983)"
LOG ""
LOG blue "═══════════════════════════════"
LOG ""

exit 0
