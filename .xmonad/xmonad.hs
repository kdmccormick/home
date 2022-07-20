
import Control.Concurrent ( threadDelay )
import Data.List ( intercalate )
import qualified Data.Map as M
import Numeric ( showHex )
import System.Directory ( doesFileExist )
import System.Exit ( exitWith, ExitCode(..) )
import System.IO ( hPutStrLn )
import System.Process ( spawnCommand, waitForProcess, readProcessWithExitCode )
import XMonad
  (
    xmonad, def,
    keys, borderWidth, normalBorderColor, focusedBorderColor, terminal,
    startupHook, manageHook, layoutHook, handleEventHook, logHook,
    X, XConfig(XConfig), WorkspaceId, ChangeLayout(NextLayout),
    spawn, windows, withFocused, sendMessage, kill, refresh,
    modMask, mod1Mask, mod4Mask, controlMask, shiftMask, noModMask,
    (|||), (.|.), (<+>)
  )
import XMonad.Actions.WithAll ( sinkAll, killAll )
import XMonad.Actions.SpawnOn ( spawnOn, manageSpawn )
import XMonad.Config.Prime  ( Resize(Shrink, Expand) )
import XMonad.Config.Xfce ( xfceConfig )
import XMonad.Hooks.EwmhDesktops
  (
    ewmh,
    ewmhDesktopsStartup, ewmhDesktopsEventHook, ewmhDesktopsLogHook,
  )
import XMonad.Hooks.ManageDocks ( manageDocks, avoidStruts, docksEventHook )
import XMonad.Layout ( Full(Full) )
import XMonad.Layout.ResizableTile
  ( MirrorResize(MirrorExpand, MirrorShrink), ResizableTall(ResizableTall) )
import XMonad.Layout.StackTile ( StackTile(StackTile) )
import XMonad.ManageHook ( composeAll, (=?), (-->), resource, className, doIgnore, doFloat, title )
import XMonad.StackSet ( focusDown, focusUp, focusMaster, swapDown, swapUp, swapMaster, shift, greedyView)
import XMonad.Util.Run ( spawnPipe, runProcessWithInput )

import qualified Graphics.X11.Types as X11T

main = do
    xmonad $ xfceConfig
          { keys = (\_ -> M.fromList $ map (\(m, k, c) -> ((m, k), c)) keybindings)
          , modMask = global
          , borderWidth = 3
          , focusedBorderColor = "#bb00ff"
          , normalBorderColor = "#220055"
          , terminal = cmdTerminal
          , startupHook = onStart
          , manageHook = myManageHook
          , layoutHook = myLayout
          , handleEventHook = docksEventHook <+> ewmhDesktopsEventHook
          , logHook    = ewmhDesktopsLogHook
          }

myManageHook = composeAll
    [ className =? "MPlayer"                    --> doFloat
    , className =? "Gimp"                       --> doFloat
    , className =? "Wpa_gui"                    --> doFloat
    , title     =? "Whisker Menu"               --> doFloat
    , title     =? "xfce4-terminal-drop-down"   --> doFloat
    , title     =? "Zoom ?.*"                   --> doFloat
--    , resource  =? "desktop_window" --> doIgnore
    , manageDocks
    , manageSpawn
    , manageHook def
    ]

myLayout = avoidStruts $ tiled ||| goldenStack ||| Full
        where
          tiled        = ResizableTall nmaster delta golden []
          goldenStack  = StackTile nmaster delta golden
          golden       = toRational (2/(1 + sqrt 5 :: Double))
          nmaster      = 1 
          delta        = 0.03

onStart :: X ()
onStart =
    ewmhDesktopsStartup >>                     -- Init EWMH stuff.
    spawn "xfce4-panel --restart" >>           -- Restart panel show XMonad respects it.
    spawn "invertscroll" >>                    -- Ensure natural scrolling direction.
    spawn "xset s 300 5" >>                    -- Lock screen after 300s; poll every 5s.
    spawn "xss-lock --notifier=/usr/local/libexec/xsecurelock/dimmer --transfer-sleep-lock -- xsecurelock"

spawnWks :: Int -> String -> X ()
spawnWks wksId cmd = spawnOn (show wksId) cmd

-- Modifier keys
noMod          = noModMask
shft           = shiftMask
alt            = mod1Mask
altShift       = alt .|. shft
super          = mod4Mask
superShift     = super .|. shft
global         = super
globalShift    = global .|. shft
globalAlt      = global .|. alt

workspaces :: [WorkspaceId]
workspaces = map show [1 .. 9 :: Int]

-- Keybindings
keybindings =

    -- Switch focusing up or down using k/j, like in vi.
    -- Use i/a for "insert" (beginning) or "append" (end).
    -- TODO: haven't figured out a good command for "append" yet.
    [ (global,        X11T.xK_k,         windows focusUp)
    , (global,        X11T.xK_j,         windows focusDown)
    , (global,        X11T.xK_i,         windows focusMaster)
    , (global,        X11T.xK_a,         return ()) -- windows focusEnd)

    -- Shift plus a key from above causes the corresponding swap.
    -- TODO: haven't figured out a good command for "append" yet.
    , (globalShift,   X11T.xK_j,         windows swapDown)
    , (globalShift,   X11T.xK_k,         windows swapUp)
    , (globalShift,   X11T.xK_i,         windows swapMaster)
    , (globalShift,   X11T.xK_a,         return ()) -- windows swapEnd)

    -- h/l to move the vertical bar left or right;
    -- H/L to move the horizontal bar up or down.
    , (global,        X11T.xK_h,         sendMessage Shrink)
    , (global,        X11T.xK_l,         sendMessage Expand)
    , (globalShift,   X11T.xK_h,         sendMessage MirrorExpand)
    , (globalShift,   X11T.xK_l,         sendMessage MirrorShrink)

    -- w/b (inspired by "word/back") to get us to cycle layouts
    -- TODO: no good function for cycle backwards?
    , (global,        X11T.xK_w,         sendMessage NextLayout)
    , (global,        X11T.xK_b,         return ()) -- sendMessage Layout)

    -- x to kill a "character" (a window); d to kill a "line" (workspace)
    , (global,        X11T.xK_x,         kill)
    , (global,        X11T.xK_d,         killAll)

    -- Whisker Menu on space
    , (global,        X11T.xK_space,     spawn cmdMenu)

    -- enter for a dropdown terminal, ENTER for a windowed one, alt+enter for sudo one.
    , (global,        X11T.xK_Return,    spawn cmdTerminalDropDown)
    , (globalShift,   X11T.xK_Return,    spawn cmdTerminal)
    , (globalAlt,     X11T.xK_Return,    spawn cmdTerminalSudo)

    -- ESC gets us back to a sane state
    , (global,        X11T.xK_Escape,    sinkAll >> refresh)

    -- Backslash key for Web browsers
    , (global,        X11T.xK_backslash, spawn cmdFirefox)
    , (globalShift,   X11T.xK_backslash, spawn cmdFirefoxProfiles)
    , (globalAlt,     X11T.xK_backslash, spawn cmdChromium)

    -- Backspace key for file browsers. Shadow built-in 'e' for that function.
    , (global,        X11T.xK_BackSpace, spawn cmdFolderHome)
    , (globalShift,   X11T.xK_BackSpace, spawn cmdFolderDownloads)
    , (globalAlt,     X11T.xK_BackSpace, spawn cmdFolderRoot)
    , (global,        X11T.xK_e,         return ())

    -- Common WiFi networks using INSERT.
	, (global,        X11T.xK_Insert,    spawn cmdWifi)
	, (globalShift,   X11T.xK_Insert,    spawn cmdWifi5)
	, (globalAlt,     X11T.xK_Insert,    spawn cmdWifiHotspot)
	
	-- Screenshots using PRINT (note: NO global mod here)
    , (noModMask,     X11T.xK_Print,     spawn cmdScreenshot)
    , (shft,          X11T.xK_Print,     spawn cmdScreenshotSelect)
    , (alt,           X11T.xK_Print,     spawn cmdScreenshotWindow)

    -- Session options using HOME.
    , (global,        X11T.xK_Home,      spawn cmdLock)
    , (globalShift,   X11T.xK_Home,      spawn cmdLogout)
    , (globalAlt,     X11T.xK_Home,      spawn cmdXMonadRestart)

    -- Power options using END.
    , (global,        X11T.xK_End,       spawn cmdSleep)
    , (globalShift,   X11T.xK_End,       spawn cmdShutdown)
    , (globalAlt,     X11T.xK_End,       spawn cmdRestart)

	-- TODO: Disabling tridactyl for now. Let Firefox intercpt <C-t> again as normal.
    -- Using "<C-t>" in firefox+tricatyl focuses the address bar and messes
    -- up the workflow. We would keybind over it via tridactyl, but that doesn't
    -- work for some reason. So, we shadow <C-t> here until I'm trained out of it.
    -- We try to simulate a 't' keybpress but it's not working, but we'll leave that
    -- here anyway.
    -- Note that this could get annoying in other programs that use <C-t>.
    --, (controlMask,   X11T.xK_t,         spawn "xdotool key t")

    ] ++

    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [(global .|. m, k, windows $ f i)
        | (i, k) <- zip workspaces [X11T.xK_1 .. X11T.xK_9]
        , (f, m) <- [(greedyView, 0), (shift, shiftMask)]]

cmdTerminalDropDown       = "xfce4-terminal --drop-down --title='xfce4-terminal-drop-down'"
cmdTerminal               = "xfce4-terminal"
cmdTerminalSudo           = "xfce4-terminal -x sudo su"

cmdFirefox                = "firefox -P $KI_USER_PROFILE"
cmdFirefoxProfiles        = "firefox -P"
cmdChromium               = "chromium-browser --new-window"

cmdFolderHome             = "thunar"
cmdFolderDownloads        = "thunar $HOME/downloads"
cmdFolderRoot             = "thunar /"

cmdWifi                   = "nmcli c u $USER-home"
cmdWifi5                  = "nmcli c u $USER-home-5"
cmdWifiHotspot            = "nmcli c u $USER-hotspot"

cmdScreenshot             = "xfce4-screenshooter --fullscreen"
cmdScreenshotSelect       = "xfce4-screenshooter --region"
cmdScreenshotWindow       = "xfce4-screenshooter --window"

cmdMenu                   = "xfce4-popup-whiskermenu"

cmdSessionDialog          = "xfce4-session-logout"

cmdLock                   = "xflock4" --"xset s activate"
cmdLogout                 = cmdSessionDialog ++ " --logout"
cmdXMonadRestartInner     = "bash -c '(xmonad --recompile && xmonad --restart) || read -p \"\nPress ENTER to continue.\"'"
cmdXMonadRestart          = "xfce4-terminal -x " ++ cmdXMonadRestartInner

cmdSleep                  = cmdSessionDialog ++ " --suspend"
cmdShutdown               = cmdSessionDialog ++ " --halt"
cmdRestart                = cmdSessionDialog ++ " --reboot"

--cmdOneMonitor             = "mon L"
--cmdTwoMonitorsVertical    = "mon a"

spawnMulti cmds = spawn $ intercalate " && " cmds

