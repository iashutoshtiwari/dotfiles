# Motion inventory

Audited 2026-09-22 against Hyprland 0.56.2 and Quickshell 0.3.1. “Unchanged”
means the item was inspected and deliberately retained; static opacity, scale,
and geometry are listed where repository-wide text search could mistake them
for animation.

| Surface / file | Previous behavior | Unified behavior | Unchanged? |
| --- | --- | --- | --- |
| Hyprland windows | 200ms `popin 94%` with one ease-out | 190ms `popin 98%` plus fade | No |
| Hyprland window close | 140ms reverse-like `popin 96%` | 130ms `popin 99%`, dedicated ease-in/fade-out | No |
| Hyprland move/resize | Inherited window interpolation | Disabled so pointer motion remains direct | No |
| Hyprland workspace | 220ms `slidefade 18%` | 230ms `slidefade 10%`, spatial curve | No |
| Special workspace / scratchpad | 180ms `slidefade 12%`; scratchpad forced `popin 94%` | 180ms fade; scratchpad `popin 98%` | No |
| Global layer in/out | 180/120ms `slide top` | 160/100ms fade in place | No |
| Rofi launcher and emoji | Inherited top-edge layer slide | Observed namespace `rofi`; explicit in-place fade | No |
| Persistent shell / wallpaper | Inherited global layer motion | Observed `quickshell` and `hyprpaper`; compositor animation disabled | No |
| Notifications / OSD layers | Could inherit compositor layer motion | Namespaced QML owners excluded from compositor motion | No |
| Wayland app popups | Inherited generic fade | Dedicated 100ms in / 80ms out fade | No |
| Focus, border, shadow fades | Generic 140ms fade | 110–120ms focus/border family; no looping shadow effect | No |
| Touchpad workspace gesture | Native three-finger Hyprland gesture | Native continuous gesture retained; no fake QML interpolation | Yes — direct gesture ownership is correct |
| `Theme.qml` | Five legacy timings: 70/110/170/240/105ms | Named 80/100/130/170/230ms family plus 90/110ms exits | No |
| Reduced motion | None | Central `Theme.reducedMotion`; transform travel/scale collapse to fade | No |
| `PopupSurface.qml` | 170/105ms, 1.5% scale, 6px rise, cubic sequence | 170/110ms, 1% scale, 4px rise; state transition remains interruptible | No |
| PopupWindow geometry adjustment | `PopupAdjustment.Slide` keeps popups onscreen | Retained as placement correction, not visual animation | Yes — prevents offscreen geometry |
| Popup switching (`Bar.qml`) | One popup hidden before another becomes visible | Retained immediate ownership handoff; surface transition has no blank delay | Yes — overlap/gap avoidance |
| Workspace marker | 170ms `x` ease-out | 230ms `x` ease-out synchronized with compositor | No |
| Workspace slot resizing | Immediate dynamic width | Structural geometry remains immediate; marker/color only animate | Yes — preserves click targets |
| Shared hover states | 110ms color changes | 100ms standard ease-out color changes | No |
| Active bar underline | Visibility snapped | 130ms in / 90ms out opacity | No |
| Icon button press | Color only | 80ms restrained 0.98 scale plus standard color | No |
| Popup rows | 110ms color | 100ms standard color | No |
| Audio/brightness sliders | Fill and thumb jumped for all changes | 100ms programmatic movement; direct while pressed/dragged | No |
| Calendar month | 105ms out + 170ms in, 8px, mixed cubics | 90ms out + 100ms in, directional 10px cross-slide | No |
| Media metadata | Whole row flashed to 35% then recovered | Full quick fade-out, 3px directional fade-in; geometry stable | No |
| Media progress | 1Hz updates jumped | Existing low-cost 1Hz cadence, 100ms fill interpolation | No |
| Media play state in bar | Icon/color snapped | 100ms color and restrained scale transition | No |
| Media popup play icon | Glyph swap in shared button | Retained instantaneous glyph swap; shared `IconButton` supplies press/color feedback | Yes — avoids duplicate icon layers |
| Notification toast lifecycle | Cards appeared/disappeared and reflowed instantly | 170ms/12px entrance, 110ms/6px exit, 170ms displaced reflow | No |
| Notification replacement | Array replacement replayed insertion and moved the card | Stable ID updates in place without add/remove motion | No |
| Notification center rows / clear all | Immediate model removal | Retained | Yes — current history model exposes no pre-removal lifecycle; avoids a costly cascade |
| OSD surface | 170ms opacity only | 170ms 1%/4px fade-scale-rise; 110ms exit | No |
| Repeated OSD updates | Existing visible card stayed open and restarted timeout | Retained; only bar/color values animate at 100ms | Yes — already satisfies no replay/backlog |
| Power/menu content in shell | PopupSurface motion; confirmation content changed in place | Unified PopupSurface motion; confirmation remains stable in-place content | Yes — avoids full-surface replay |
| Wallpaper thumbnails | Immediate overlay/selection visuals | Shared row/button hover motion where used; no thumbnail scale | Yes — restrained and avoids texture churn |
| Greeter initial content | 200ms opacity fade | 190ms opacity plus 4px rise | No |
| Greeter focus/actions | 120ms un-eased colors | 100ms standard ease-out colors | No |
| Greeter power menu | 120ms opacity | 100ms in/out opacity plus 1% scale | No |
| Greeter Hyprland compositor | Animations disabled | Retained | Yes — QML owns motion and login must not be delayed |
| Hyprlock | `--no-fade-in`; no authored motion | Retained clean immediate lock/unlock | Yes — no reliable animation API needed |
| Hypridle | Timers and DPMS commands only | No visual motion added | Yes — not animation code |
| Rofi `.rasi` files | No authored animation | No fake Rasi motion added | Yes — compositor owns Rofi fade |
| Static wallpaper SVG opacity | Fixed decorative alpha values | Retained | Yes — static paint, not animation |
| Kitty opacity / generated comments | Fixed background alpha; example animation comments disabled | Retained | Yes — not active motion configuration |
| Service timers | Polling/state maintenance | Retained | Yes — no visual animation or render loop |

No repository file containing active `Animation`, `Behavior`, `Transition`,
easing, or Hyprland animation rules was omitted. Documentation prose and static
alpha/scale matches were inspected and classified above rather than modified as
motion.
