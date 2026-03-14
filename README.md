# Perspective Grid Tool (Moho 14.x)

## Files
- `tool/pg_perspective_grid.lua`
- `tool/pg_perspective_grid.png`
- `tool/pg_perspective_grid@2x.png`

## Current behavior
- Tool name in Moho: `Perspective Grid`
- One setting only: `Lines`
- Click-drag workflow:
1. Mouse-down sets the center point (vanishing center).
2. Drag sets the radius/extent.
3. Mouse-up generates a radial fan of perspective guide lines.
- Generated lines are isolated 2-point segments.

## How to use
1. Install/copy files into your active Moho `Tool` scripts folder.
[Download ZIP](https://github.com/ilivetruth/perspective-grid/archive/refs/heads/main.zip)Extract
3. Restart Moho.
4. Select `Perspective Grid`. (Vector layer must be selected, adds a new button under "Other" at the bottom of the drawing toolbar. 
5. Set `Lines` (default `99`).
6. Click and drag in the canvas to generate guides.
7. Move/edit generated points manually as needed.
[![Video Title](https://img.youtube.com/vi/WhMojmPIMV0/0.jpg)](https://www.youtube.com/watch?v=WhMojmPIMV0)

## Credits
- Creator metadata in script: `Earl B (ilivetruth.com)`

## Tool list section note (`_tool_list.txt`)
By default, custom tools may appear under `Other`.  
If you want this tool under a `Perspective` section, manually append this block to your active:
- `Tool/_tool_list.txt`

```txt
group MOHO.Localize("/Tools/Group/Perspective=Perspective")
tool    pg_perspective_grid    ...
```

Notes:
- Add the block once only.
- Restart Moho after editing.
- This is safer than replacing `_tool_list.txt` during install.
