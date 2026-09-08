" redlight — low-light red-on-black colorscheme for the host's "redlight"
" theme mode. Plain vimscript (no plugin dependency) so it applies even
" before lazy.nvim loads; selected by init.lua when ~/.local/state/theme/mode
" contains "redlight" (written by theme-set), and pushed live to running
" instances via :colorscheme redlight over their sockets.
" Palette: monochrome red ramp on #000000; amber #d4763a is the single hue
" break for warnings/search/statusline so states stay distinguishable.
set background=dark
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'redlight'

" ── editor chrome ─────────────────────────────────────────────
hi Normal          guifg=#d43a3a guibg=#000000
hi NormalFloat     guifg=#d43a3a guibg=#0a0505
hi FloatBorder     guifg=#2a1010 guibg=#0a0505
hi Cursor          guifg=#000000 guibg=#ff4a4a
hi CursorLine      guibg=#0f0505
hi CursorColumn    guibg=#0f0505
hi LineNr          guifg=#4a1a1a
hi CursorLineNr    guifg=#ff4a4a gui=bold
hi SignColumn      guibg=#000000
hi ColorColumn     guibg=#0f0505
hi VertSplit       guifg=#2a1010
hi WinSeparator    guifg=#2a1010
hi StatusLine      guifg=#d4763a guibg=#1a0a0a
hi StatusLineNC    guifg=#4a1a1a guibg=#0a0505
hi TabLine         guifg=#4a1a1a guibg=#0a0505
hi TabLineSel      guifg=#ff4a4a guibg=#1a0a0a gui=bold
hi TabLineFill     guibg=#000000
hi Pmenu           guifg=#d43a3a guibg=#1a0a0a
hi PmenuSel        guifg=#ff6a5a guibg=#330f0f
hi PmenuSbar       guibg=#1a0a0a
hi PmenuThumb      guibg=#4a1a1a
hi Visual          guibg=#330f0f
hi VisualNOS       guibg=#330f0f
hi Search          guifg=#000000 guibg=#d4763a
hi IncSearch       guifg=#000000 guibg=#ff9e50 gui=bold
hi CurSearch       guifg=#000000 guibg=#ff9e50 gui=bold
hi MatchParen      guifg=#ff9e50 guibg=#2a1010 gui=bold
hi NonText         guifg=#2a1010
hi Whitespace      guifg=#2a1010
hi SpecialKey      guifg=#2a1010
hi Folded          guifg=#8a2828 guibg=#0a0505
hi FoldColumn      guifg=#4a1a1a guibg=#000000
hi Directory       guifg=#d4763a
hi Title           guifg=#ff4a4a gui=bold
hi Question        guifg=#d4763a
hi MoreMsg         guifg=#d4763a
hi ModeMsg         guifg=#d43a3a
hi ErrorMsg        guifg=#ff2020 gui=bold
hi WarningMsg      guifg=#d4763a
hi WildMenu        guifg=#ff6a5a guibg=#330f0f
hi Conceal         guifg=#4a1a1a
hi Underlined      guifg=#d4763a gui=underline
hi Todo            guifg=#ff9e50 guibg=#1a0a0a gui=bold
hi SpellBad        guisp=#ff2020 gui=undercurl
hi SpellCap        guisp=#d4763a gui=undercurl
hi SpellLocal      guisp=#8a2828 gui=undercurl
hi SpellRare       guisp=#8a2828 gui=undercurl

" ── syntax ────────────────────────────────────────────────────
hi Comment         guifg=#4a1a1a gui=italic
hi Constant        guifg=#e05050
hi String          guifg=#b34538
hi Character       guifg=#b34538
hi Number          guifg=#ff6a5a
hi Boolean         guifg=#ff6a5a
hi Float           guifg=#ff6a5a
hi Identifier      guifg=#d43a3a
hi Function        guifg=#ff6a5a
hi Statement       guifg=#ff4a4a gui=bold
hi Conditional     guifg=#ff4a4a gui=bold
hi Repeat          guifg=#ff4a4a gui=bold
hi Label           guifg=#ff4a4a
hi Operator        guifg=#e06a3a
hi Keyword         guifg=#ff4a4a gui=bold
hi Exception       guifg=#ff2020 gui=bold
hi PreProc         guifg=#e06a3a
hi Include         guifg=#e06a3a
hi Define          guifg=#e06a3a
hi Macro           guifg=#e06a3a
hi PreCondit       guifg=#e06a3a
hi Type            guifg=#d4763a
hi StorageClass    guifg=#d4763a
hi Structure       guifg=#d4763a
hi Typedef         guifg=#d4763a
hi Special         guifg=#b3573a
hi SpecialChar     guifg=#b3573a
hi Tag             guifg=#d4763a
hi Delimiter       guifg=#8a2828
hi SpecialComment  guifg=#8a2828
hi Debug           guifg=#ff2020
hi Ignore          guifg=#2a1010
hi Error           guifg=#ff2020 gui=bold

" ── diagnostics / diff ────────────────────────────────────────
hi DiagnosticError guifg=#ff2020
hi DiagnosticWarn  guifg=#d4763a
hi DiagnosticInfo  guifg=#8a2828
hi DiagnosticHint  guifg=#4a1a1a
hi DiagnosticUnderlineError guisp=#ff2020 gui=undercurl
hi DiagnosticUnderlineWarn  guisp=#d4763a gui=undercurl
hi DiagnosticUnderlineInfo  guisp=#8a2828 gui=undercurl
hi DiagnosticUnderlineHint  guisp=#4a1a1a gui=undercurl
hi DiffAdd         guifg=#b34538 guibg=#0f0505
hi DiffChange      guifg=#d4763a guibg=#0f0505
hi DiffDelete      guifg=#ff2020 guibg=#0f0505
hi DiffText        guifg=#ff9e50 guibg=#1a0a0a
hi Added           guifg=#b34538
hi Changed         guifg=#d4763a
hi Removed         guifg=#ff2020

" ── @capture links (LSP semantic tokens fall back to these) ──
hi def link @comment Comment
hi def link @string String
hi def link @keyword Keyword
hi def link @function Function
hi def link @function.builtin Special
hi def link @variable Identifier
hi def link @variable.parameter Normal
hi def link @type Type
hi def link @constant Constant
hi def link @constant.builtin Constant
hi def link @operator Operator
hi def link @punctuation Delimiter
hi def link @markup.heading Title
hi def link @markup.link Underlined

" ── telescope ─────────────────────────────────────────────────
hi TelescopeNormal       guifg=#d43a3a guibg=#0a0505
hi TelescopeBorder       guifg=#2a1010 guibg=#0a0505
hi TelescopeSelection    guifg=#ff6a5a guibg=#330f0f
hi TelescopeMatching     guifg=#d4763a gui=bold
hi TelescopePromptPrefix guifg=#d4763a
