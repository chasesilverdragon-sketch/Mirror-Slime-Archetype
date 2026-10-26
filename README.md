# Mirror Slime — Yu-Gi-Oh! Custom Archetype

**Version 1.0.0 · First public playtest release**  
**Created by Chase Johnson**

Mirror Slime is a fan-made Yu-Gi-Oh! archetype built around six Attribute-based Slimes, Fusion Summoning, Pendulum support, and King and Queen Rainbow Slime. The complete pack contains custom card scripts, artwork, a card database, and a ready-to-use deck.

This is an unofficial fan project. It is not affiliated with or endorsed by Konami.

## Download and install

Download **[`Mirror_Slime_v1.0.0.ypk`](Mirror_Slime_v1.0.0.ypk)**. This is the **playable card pack**; the repository ZIP itself is not the in-game pack.

To install using the built-in MDPro4 downloader:

1. Open the `Mirror_Slime_v1.0.0.ypk` file page on GitHub and copy its **Raw** file URL.
2. Open **MDPro4 → Settings → Expansions → Download Custom Card Pack**.
3. Paste the Raw `.ypk` URL and download the pack.
4. Locate the cards in the deck editor using the **Custom** filter. A 40-card Main Deck and nine-card Extra Deck profile is included in the pack.

If you already installed an older **Mirror Slime** playtest pack, replace or disable that specific old pack first so duplicated custom card IDs cannot conflict. Do not remove unrelated expansions.

**Important for GitHub publishers:** This README's relative download link works once the contents of this folder are uploaded to a public repository. For in-game downloading, share the **Raw** link to the `.ypk` file, not the GitHub repository URL or this README.

## What's included

| Category | Cards |
| --- | --- |
| Six Attribute monsters | Mirror Slime – Red, Blue, Green, Yellow, Purple, Brown |
| Pendulum monsters | Prism Scale Slime – Pure; Prism Scale Slime – Inversion |
| Other Main Deck monster | Prism Warp Slime |
| Extra Deck | King Rainbow Slime; Queen Rainbow Slime; Prism Slime Knight |
| Spells and Traps | Mirror Barrier; Mirror Pool; Mirror Reversal; Prism Fusion; Prism Mirror Coat; Prism Reflection; Prism Reformation; Prism Scale Shift |

**20 playable custom cards** are supplied, with art and Lua scripts. The database includes one additional **non-playable internal text entry** used to display King's effect-selection options correctly in MDPro4.

### Deck identity

- **King Rainbow Slime:** Fusion Summon using **3 to 6** Mirror Slimes with *different Attributes*. More Attributes unlock more benefits; you do **not** have to use all six.
- **King's effect choices:** If DARK and WATER/Blue bonuses are both available, choose **Banish 1 card**, **Reduce ATK**, or **Use both effects**. Each bonus has its own once-per-turn usage limit.
- **Queen Rainbow Slime:** Link Monster that supports Fusion Monsters.
- **Prism Slime Knight:** Fusion/Pendulum boss monster.
- **Mirror Slime – Purple:** Can send a different Mirror Slime from Deck to GY when sent to the GY **except as Fusion Material**; its separate Fusion-material bonus destroys a card.

## Compatibility and testing

- Developed and locally playtested on **MDPro4 v1.0.4 on Windows** against a local WindBot opponent.
- No known gameplay issues were reported by the original tester at the time of the first public release.
- Other clients, MDPro3 versions, Android, and online multiplayer have **not** been comprehensively verified. Feedback is welcome.

This release preserves the working game files from internal playtest **v40**, with no last-minute effect changes.

## Repository files

- `Mirror_Slime_v1.0.0.ypk` — direct installation pack (card art, scripts, database, and deck).
- `source/` — the same editable card database, Lua scripts, artwork, and `.ydk` deck list used to build the pack.
- `CHANGELOG.md` — release history.
- `RELEASE_NOTES.md` — text to use when announcing the release.
- `PUBLISHING_GUIDE.md` — steps for uploading this package to GitHub and sharing the proper link.

## Reporting a problem

Open a GitHub Issue and include:

1. MDPro4/client version and platform.
2. Name of the Mirror Slime card and the exact effect involved.
3. How the card was Summoned or sent to the GY (including Fusion Materials when relevant).
4. Whether an effect failed to appear, resolved incorrectly, or froze a Select/Cancel prompt.
5. A screenshot or sanitized log excerpt, if available.

## Credits and permissions

**Original archetype concept and card design:** Chase Johnson.  
**Playtesting and creative direction:** Chase Johnson.  
**Development support:** ChatGPT-assisted art, documentation, and Lua scripting.

Yu-Gi-Oh! and related trademarks belong to their respective rights holders. The pack is shared as a free, noncommercial fan-made playtest project.

No general-purpose code or artwork license is included with this initial release. Contact the project creator about redistribution, modifications, or reuse beyond trying the pack. You can add an explicit license later if you want to invite community remixes or code contributions.
