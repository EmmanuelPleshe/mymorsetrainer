# Morse Trainer — Domain Glossary

## Characters

**Morse Code Character** — A single symbol represented as a sequence of dots (.) and dashes (-). The full character set follows ITU-R M.1677.

**Koch Sequence** — The ordered list of characters introduced progressively during Koch-method training. Each lesson adds characters to the active pool; the learner must achieve 90% accuracy on all unlocked characters before advancing. The sequence covers letters, digits, punctuation (full ITU set), and common prosigns.

**Prosign** — A procedural signal formed by two or three letters sent with *no inter-character space* (e.g., `AR` end of message, `SK` end of contact, `BT` break). Played as a single continuous sound, not as separate letters. Prosigns appear last in the Koch sequence because they require contextual understanding. The coordinator must suppress inter-character pauses when playing a prosign.

**Q-Code** — A three-letter code starting with Q used in amateur radio (e.g., QSO = contact, QSL = acknowledgment, QRL = frequency in use). Sent as regular characters with normal spacing. Part of the QSO vocabulary practice set, not the Koch sequence.

**CW Abbreviation** — A short shorthand used in CW contacts (e.g., CQ = calling any station, DE = from, K = over, 73 = best regards). Sent as regular characters with normal spacing. Part of the QSO vocabulary practice set, not the Koch sequence.

## Modules

**MorseCodeMapper** — A pure module that owns the Morse code character map and the Koch sequence. Translates between characters and dot/dash patterns, and determines which characters are active at a given Koch level. Has no dependency on audio, timing, or playback.

**AudioPlaybackService** — The module responsible for tone generation and playback. Knows how to produce a tone at a given frequency for a given duration and how to insert silence. Owns timing parameters (WPM, Farnsworth speed, volume). Has no knowledge of Morse tables or Koch progression.

**MorseCodeCoordinator** — The thin orchestration layer that depends on both MorseCodeMapper and AudioPlaybackService. Given a word or string, it asks the mapper for the Morse pattern, then sequences tones and pauses through the audio service. This is the only place where Morse logic and audio logic meet.