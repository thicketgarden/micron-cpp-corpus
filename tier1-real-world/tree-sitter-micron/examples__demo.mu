#!c=3600
#!fg=ddd
#!bg=111
# This is a comprehensive Micron demo document
# It exercises every syntax feature for testing

>Micron Feature Showcase

Welcome to the `!Micron`! markup language demo. This document demonstrates `*every`* feature available in micron.

>>Text Formatting

You can make text `!bold`!, `_underlined`_, or `*italic`*.
You can also `!`_`*combine them all`*`_`! for emphasis.

Use `` to reset all formatting back to defaults.

>>>Alignment

`cThis text is centered.
`rThis text is right-aligned.
`lThis text is left-aligned.
`aBack to default alignment.

>>Colors

`F0f0Green text`f, `Ff00red text`f, and `F00fblue text`f.

True color: `FT8844ccPurple text`f with 24-bit precision.

Background colors: `B5d5`F222highlighted text`f`b back to normal.

True color background: `BTff88001`F000orange background`f`b.

>>Links

Simple URL link: `[72914442a3689add83a09a767963f57c:/page/index.mu]

Labeled link: `F79d`_`[Click here`72914442a3689add83a09a767963f57c:/page/index.mu]`_`f

Link with fields: `[Submit`:/page/handler.mu`username|auth_token]

Link with all fields: `[Send All`:/page/handler.mu`*]

Link with variables: `[Query`:/page/search.mu`q=hello|page=1]

Anchor link: `[Jump to Tables`#tables]

>`:demo-anchor Anchors

This section has an explicit anchor named `!demo-anchor`!.

Headers also generate auto-anchors from their slugified text.

>Tables

`tc
| Feature | Status | Notes |
| ------- | :----: | ----: |
| `!Bold`! | `F0a0Done`f | Complete |
| `*Italic`* | `F0a0Done`f | Complete |
| Colors | `F0a0Done`f | 3+6 digit |
`t

Left-aligned table with max width:
`tl80
| Name | Value |
| ---- | ----- |
| Alpha | 1 |
| Beta | 2 |
`t

>Fields & Requests

>>Text Inputs

Simple field: `B444`<username`JohnDoe>`b

Empty field: `B444`<email`>`b

Sized field: `B444`<16|nickname`>`b

Masked field: `B444`<!|password`secret>`b

Full options: `B444`<!32|api_key`hidden-value>`b

>>Checkboxes

`B444`<?|agree_tos|yes`>`b I agree to the Terms of Service

`B444`<?|newsletter|yes|*`>`b Subscribe to newsletter (pre-checked)

>>Radio Buttons

`B900`<^|color|Red`>`b Red
`B090`<^|color|Green`>`b Green
`B009`<^|color|Blue`>`b Blue

>Dividers

Plain divider:
-

Custom character divider:
-~

Unicode divider:
-═

>Literals

Here is a literal block showing micron source code:
`=
>This heading is NOT parsed
`!This bold is NOT parsed`!
`Faaa colors are NOT parsed `f
# This comment is NOT parsed
`=

>Partials

Simple partial:
`{f64a846313b874ee4a357040807f8c77:/page/content.mu}

Auto-refreshing partial (every 10 seconds):
`{f64a846313b874ee4a357040807f8c77:/page/status.mu`10}

Partial with fields:
`{f64a846313b874ee4a357040807f8c77:/page/dynamic.mu`5`pid=42|username}

>Comments

# This line is a comment and will not be displayed
The line above is invisible to the reader.

>Escapes

Escaped backtick: \`
Escaped backslash: \\
\>This is NOT a heading because the > is escaped

>Section Depth Reset

>>>Deep Section
This text is deeply indented.

>>>>Even Deeper
Very deep indentation here.

<
Back to root level after the section reset.

>Closing

Thank you for reviewing this `!Micron`! feature showcase.
For more information, see the `_`[NomadNet documentation`a8d24177d946de4f1f0a0fe1af9a1338:/page/index.mu]`_.
