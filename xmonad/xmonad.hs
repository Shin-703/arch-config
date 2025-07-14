--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.SpawnOnce
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageDocks
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- dbus
import XMonad.Hooks.DynamicLog
import qualified XMonad.DBus as D
import qualified DBus.Client as DC

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9", "10"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#005555"
myFocusedBorderColor = "#77aaff"

increaseBrightness = "echo $(($(cat /sys/class/backlight/intel_backlight/brightness)+10000)) > /sys/class/backlight/intel_backlight/brightness"
decreaseBrightness = "echo $(($(cat /sys/class/backlight/intel_backlight/brightness)-10000)) > /sys/class/backlight/intel_backlight/brightness"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch rofi show -drun
    , ((modm,               xK_o     ), spawn "rofi -theme main -show drun -icon-theme 'Papirus' -show-icons")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm,               xK_c     ), kill)

    -- Rotate through the available layout algorithms
    , ((modm,               xK_r ), sendMessage NextLayout)

    -- Full Screen
    , ((modm,               xK_f ), sendMessage (Toggle "Full") <+> sendMessage ToggleStruts)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown  )

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown  )

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp    )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster)

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_m     ), windows W.swapMaster )

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown   )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp     )

    -- No Border
    --, ((modm,               xK_B     ), )

    -- Middle line moves left
    , ((modm,               xK_h     ), sendMessage $ ExpandTowards L)

    -- Middle line moves right
    , ((modm,               xK_l     ), sendMessage $ ExpandTowards R)
    
    -- Middle line moves down
    , ((modm,               xK_d     ), sendMessage $ ExpandTowards D)
    
    -- Middle line moves right
    , ((modm,               xK_u     ), sendMessage $ ExpandTowards U)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Manage screens
    , ((modm              , xK_s     ), spawn "arandr")

    -- Sleep mode
    , ((0, xF86XK_Sleep), spawn "xset dpms force off && slock")

    -- Screenshots
    , ((modm .|. shiftMask, xK_s     ), spawn "flameshot gui -c")

    -- Sound keys
    , ((0                 , xF86XK_AudioRaiseVolume ), spawn "pactl set-sink-volume 0 +5%")
    , ((0                 , xF86XK_AudioLowerVolume ), spawn "pactl set-sink-volume 0 -5%")
    , ((0                 , xF86XK_AudioMute        ), spawn "pactl set-sink-mute 0 toggle")

    -- Brightness keys
    , ((0                 , xF86XK_MonBrightnessUp  ), spawn increaseBrightness)
    , ((0                 , xF86XK_MonBrightnessDown), spawn decreaseBrightness)

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_4,xK_5,xK_6,xK_7,xK_8,xK_9,xK_0]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e}, Switch to physical/Xinerama screens 1 or 2
    -- mod-shift-{w,e}, Move client to screen 1 or 2
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
myLayout = avoidStruts $ toggleLayouts (noBorders Full) ((spacingWithEdge 4 $ tiled) ||| (spacingWithEdge 4 $ Mirror tiled) ||| (spacingWithEdge 4 $ Full))
  where
     -- tiling algorithm
     tiled   = emptyBSP 

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--

-- colors
darkGreen = "#007755"
fg        = "#8abeb7"
bg        = "#272727"
color1    = "#aa00bb"
color2    = "#5555bb"
color3    = "#0077bb"
color4    = "#008844"
color5    = "#997700"
color6    = "#aa6600"
color7    = "#bb0000"
color8    = "#373737"
color9    = "#373737"
color10   = "#373737"

color1b    = "#330033"
color2b    = "#111144"
color3b    = "#001155"
color4b    = "#003300"
color5b    = "#333000"
color6b    = "#442000"
color7b    = "#400000"
color8b    = "#272727"
color9b    = "#272727"
color10b    = "#272727"

-- The gay bar
--
myLogHookGay :: DC.Client -> PP
myLogHookGay dbus =  def
    { ppOutput = D.send dbus
    , ppCurrent = (\w -> case w of
            "1"  ->  wrap ("%{B" ++ color1 ++ "}  ") "  %{B-}" w
            "2"  ->  wrap ("%{B" ++ color2 ++ "}  ") "  %{B-}" w
            "3"  ->  wrap ("%{B" ++ color3 ++ "}  ") "  %{B-}" w
            "4"  ->  wrap ("%{B" ++ color4 ++ "}  ") "  %{B-}" w
            "5"  ->  wrap ("%{B" ++ color5 ++ "}  ") "  %{B-}" w
            "6"  ->  wrap ("%{B" ++ color6 ++ "}  ") "  %{B-}" w
            "7"  ->  wrap ("%{B" ++ color7 ++ "}  ") "  %{B-}" w
            "8"  ->  wrap ("%{B" ++ color8 ++ "}  ") "  %{B-}" w
            "9"  ->  wrap ("%{B" ++ color9 ++ "}  ") "  %{B-}" w
            "10" ->  wrap ("%{B" ++ color10 ++ "}  ") "  %{B-}" w
      )
    , ppVisible = wrap ("%{B" ++ fg ++ "}  ") "  %{B-}"
    --, ppUrgent = wrap ("%{F" ++ darkGreen ++ "}  ") "  %{F-}"
    , ppHidden = (\w -> case w of
            "1"  ->  wrap ("%{B" ++ color1b ++ "}  ") "  %{B-}" w
            "2"  ->  wrap ("%{B" ++ color2b ++ "}  ") "  %{B-}" w
            "3"  ->  wrap ("%{B" ++ color3b ++ "}  ") "  %{B-}" w
            "4"  ->  wrap ("%{B" ++ color4b ++ "}  ") "  %{B-}" w
            "5"  ->  wrap ("%{B" ++ color5b ++ "}  ") "  %{B-}" w
            "6"  ->  wrap ("%{B" ++ color6b ++ "}  ") "  %{B-}" w
            "7"  ->  wrap ("%{B" ++ color7b ++ "}  ") "  %{B-}" w
            "8"  ->  wrap ("%{F" ++ color8b ++ "}  ") "  %{F-}" w
            "9"  ->  wrap ("%{F" ++ color9b ++ "}  ") "  %{F-}" w
            "10" ->  wrap ("%{F" ++ color10b ++ "}  ") "  %{F-}" w

      )

    , ppHiddenNoWindows = (\w -> case w of
            "1"  ->  wrap ("%{B" ++ color1b ++ "}  ") "  %{B-}" w
            "2"  ->  wrap ("%{B" ++ color2b ++ "}  ") "  %{B-}" w
            "3"  ->  wrap ("%{B" ++ color3b ++ "}  ") "  %{B-}" w
            "4"  ->  wrap ("%{B" ++ color4b ++ "}  ") "  %{B-}" w
            "5"  ->  wrap ("%{B" ++ color5b ++ "}  ") "  %{B-}" w
            "6"  ->  wrap ("%{B" ++ color6b ++ "}  ") "  %{B-}" w
            "7"  ->  wrap ("%{B" ++ color7b ++ "}  ") "  %{B-}" w
            "8"  ->  wrap ("%{F" ++ color8b ++ "}  ") "  %{F-}" w
            "9"  ->  wrap ("%{F" ++ color9b ++ "}  ") "  %{F-}" w
            "10" ->  wrap ("%{F" ++ color9b ++ "}  ") "  %{F-}" w

      )

    , ppWsSep = ""
    , ppSep = ""
    , ppLayout = return ""
    , ppTitle = return ""
    } 

-- The simpler bar
myLogHook :: DC.Client -> PP
myLogHook dbus =  def
    { ppOutput = D.send dbus
    , ppCurrent = wrap ("%{B" ++ darkGreen ++ "}  ") "  %{B-}"
    , ppVisible = wrap ("%{B" ++ fg ++ "}  ") "  %{B-}"
    , ppHidden = wrap ("%{F" ++ fg ++ "}  ") "  %{F-}"
    , ppHiddenNoWindows = wrap ("%{F" ++ bg ++ "}  ") "  %{F-}"
    , ppWsSep = ""
    , ppSep = ""
    , ppLayout = return ""
    , ppTitle = return ""
    }




------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
    spawnOnce "~/.config/polybar/launch.sh &"
    spawnOnce "feh --bg-fill ~/Pictures/Wallpapers/sky.jpg"
    spawnOnce "picom --config ~/.config/picom.conf"
    spawn "~/.config/xrandr/hdmi"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO ()
main = do
    -- Connect to DBus
    dbus <- D.connect
    -- Request access (needed when sending messages)
    D.requestAccess dbus
    -- start xmonad
    xmonad $ def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = dynamicLogWithPP (myLogHook dbus),
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Enter  Launch xterminal",
    "mod-o            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
