>Markup & Color Display Test


`cYou can use this section to gauge how well your terminal reproduces the various types of formatting used by Nomad Network.
``


>>>>>>>>>>>>>>>>>>>>
-∿
<


>>
`a`!This line should be bold, and aligned to the left`!

`c`*This one should be italic and centered`*

`r`_And this one should be underlined, aligned right`_
``

The following line should contain a red gradient bar:
`B100 `B200 `B300 `B400 `B500 `B600 `B700 `B800 `B900 `Ba00 `Bb00 `Bc00 `Bd00 `Be00 `Bf00`b

The following line should contain a green gradient bar:
`B010 `B020 `B030 `B040 `B050 `B060 `B070 `B080 `B090 `B0a0 `B0b0 `B0c0 `B0d0 `B0e0 `B0f0`b

The following line should contain a blue gradient bar:
`B001 `B002 `B003 `B004 `B005 `B006 `B007 `B008 `B009 `B00a `B00b `B00c `B00d `B00e `B00f`b

The following line should contain a grayscale gradient bar:
`Bg06 `Bg13 `Bg20 `Bg26 `Bg33 `Bg40 `Bg46 `Bg53 `Bg59 `Bg66 `Bg73 `Bg79 `Bg86 `Bg92 `Bg99`b

Unicode Glyphs   : ✓  ✕  ⚠  Ⓝ  ↓

Nerd Font Glyphs :   󰓅  󰈙  󰀂      


>>Nerd Font Rendering Test

`cSince Nerd Font glyphs and true-color are enabled by default, the rows below should render as crisp icons rather than empty squares, question marks, or fallback ASCII. If any glyph appears blank or boxed, your terminal is not using a Nerd Font, or the font is missing the required glyph range.
``

>>>
Common UI icons   :             
Status / state    : 󰓅  󰈙  󰀂  󱎗  󱋼  󰅖
Network / radio   : 󰖩  󰖪  󰖫  󰖬    
People / messaging:           
Devices / files   :           
<

`cIf the above renders correctly, you have a working Nerd Font setup and can leave the defaults as-is. If not, see the `*First Time Information`* topic for install instructions.
``

>>Image Rendering Test

`(The RNS logo`w=n`a=c`:/media/demo.webp)

If you see the RNS logo above, your terminal supports image rendering! If not, you can use a terminal that supports the Kitty Terminal Graphics Protocol, for example Kitty, Konsole, Wezterm, iTerm2 and others.

It is also important to note, that for image rendering to work, your operating system will need `*some sort`* of mechanism to actually decode the WebP format. Nomadnet will attempt to detect a suitable decoding backend on your system, and should be able to do so on 99% of variants across Linux, BSD, macOS and Windows, as long as `Faaalibwebp`f or one of the fallback decoders are available. If all else fails, you can install PIL (`Faaapip install pillow`f) or download the open-source `Faaadwebp`f decoder utility and place it on your path (for example at `Faaa~/.local/bin/dwebp`f); nomadnet will auto-detect either.

