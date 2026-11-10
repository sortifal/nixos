# Neovim cheat sheet

Keybindings for the Neovim setup in [`home/neovim.nix`](home/neovim.nix).
`<space>` is the leader key. Press it and wait: which-key lists everything
below, grouped under **g → Git** and **h → Hunks**.

Set up for a Swiss German QWERTZ keyboard: `[` and `]` need AltGr, so
**`ö` works as `[` and `ä` works as `]`** in every mapping (the bracket keys
still work too). Read `äh` as "next hunk", `öh` as "previous hunk".

## File explorer (`Ctrl+b`)

| Key | Action |
|---|---|
| `Enter` / `o` | Expand or collapse a folder, open a file |
| `+` | Enter the folder (make it the tree root) |
| `-` | Go up one level |
| `E` / `W` | Expand all / collapse all |
| `C` | Show only changed files |
| `äc` / `öc` | Next / previous changed file |
| `g?` | All explorer keys |

## Files and search

| Key | Action |
|---|---|
| `Ctrl+b` | File explorer (keys above) |
| `Ctrl+p` / `<space>ff` | Find files |
| `Ctrl+Shift+f` / `<space>fg` | Search in files |
| `<space>fb` | Open buffers |
| `<space>fd` | Diagnostics |

## Code (LSP)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `<space>rn` | Rename |
| `<space>ca` | Code action |
| `<space>f` | Format |
| `Ctrl+Space` | Trigger completion (`Tab` / `Shift+Tab` to move, `Enter` to accept) |
| `gcc` / `gc` (visual) | Toggle comment |

## Git: overview

| Key | Action |
|---|---|
| `<space>gg` | **Lazygit** in a floating window ("edit file" opens it in this Neovim) |
| `<space>gf` | Changed files, with diff preview |
| `<space>gd` | Toggle side-by-side diff of uncommitted changes |
| `<space>gm` | Toggle diff of the branch against `origin/main` (PR-style review) |
| `<space>gh` | History of the current file |
| `<space>gH` | History of the whole repo |
| `<space>gb` | Branches |
| `<space>gq` | Close the diff view |
| `<space>gs` | Git status (fugitive) |
| `<space>gc` | Commit |
| `<space>gp` | Push |

## Git: changes in the current file (hunks)

| Key | Action |
|---|---|
| `äh` / `öh` | Next / previous changed block |
| `<space>hs` | Stage the block (again to unstage); in visual mode only the selected lines |
| `<space>hr` | Undo the block; in visual mode only the selected lines |
| `<space>hS` / `<space>hR` | Stage / undo the whole file |
| `<space>hp` | Preview the change in a popup |
| `<space>hi` | Preview the change inline (deleted lines shown in place) |
| `<space>hd` | Diff the file against the index |
| `<space>hw` | Toggle word-level diff |
| `<space>hl` | Toggle line highlights |
| `<space>hb` | Blame the current line (full commit) |
| `<space>hB` | Blame the whole file |
| `<space>ht` | Toggle the inline blame after the current line |
| `ih` | Text object for a changed block (`dih`, `yih`, `vih`) |

## Merge conflicts

During a merge or rebase, `<space>gd` opens a 3-way view
(ours | result | theirs).

| Key | Action |
|---|---|
| `äx` / `öx` | Next / previous conflict |
| `<space>co` | Take ours |
| `<space>ct` | Take theirs |
| `<space>cb` | Take base |
| `<space>ca` | Take all |
| `dx` | Delete the conflict region |

## Always on

- Gutter signs for added, changed and deleted lines.
- Faint blame after the current line, half a second after the cursor stops.
- Statusline shows the branch and `+added ~changed -removed` counts.
- Changed files and their folders are coloured in the explorer.
