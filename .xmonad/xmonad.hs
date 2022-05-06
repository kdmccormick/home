
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
    keys, borderWidth, normalBorderColor, focusedBorderColor, terminal, modMask,
    startupHook, manageHook, layoutHook, handleEventHook, logHook,
    X, XConfig(XConfig), WorkspaceId, ChangeLayout(NextLayout),
    spawn, windows, withFocused, sendMessage, kill, refresh,
    mod1Mask, mod4Mask, noModMask, shiftMask,
    (|||), (.|.), (<+>)
  )
import XMonad.Actions.SinkAll ( sinkAll )
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
    [ (global,        X11T.xK_j,         windows focusDown)
    , (global,        X11T.xK_k,         windows focusUp)
    , (global,        X11T.xK_i,         windows focusMaster)
--    , (global,        X11T.xK_a,         windows focusEnd)
    , (globalShift,   X11T.xK_j,         windows swapDown)
    , (globalShift,   X11T.xK_k,         windows swapUp)
    , (globalShift,   X11T.xK_i,         windows swapMaster)
--    , (globalShift,   X11T.xK_a,         windows swapEnd)
    , (global,        X11T.xK_h,         sendMessage Shrink)
    , (global,        X11T.xK_l,         sendMessage Expand)
    , (globalShift,   X11T.xK_h,         sendMessage MirrorExpand)
    , (globalShift,   X11T.xK_l,         sendMessage MirrorShrink)
    , (global,        X11T.xK_x,         kill)
    , (global,        X11T.xK_space,     spawn cmdMenu)
    , (global,        X11T.xK_Return,    spawn cmdTerminalDropDown)
    , (globalShift,   X11T.xK_Return,    spawn cmdTerminal)
    , (global,        X11T.xK_a,         spawn cmdTerminal >> windows swapDown)
    , (global,        X11T.xK_Escape,    sinkAll >> refresh)
	, (global,        X11T.xK_w,         sendMessage NextLayout)
--    , (globalShift,   X11T.xK_f,         spawn cmdFirefox)
--    , (globalShift,   X11T.xK_w,         spawn cmdChromium)
--    , (globalShift,   X11T.xK_e,         spawn cmdTextEditor)
    , (global,        X11T.xK_BackSpace, spawn cmdLock)
    , (globalShift,   X11T.xK_BackSpace, spawn cmdLogout)
    , (globalAlt,     X11T.xK_BackSpace, spawn cmdXMonadRestart)
    , (global,        X11T.xK_Delete,    spawn cmdSleep)
    , (globalShift,   X11T.xK_Delete,    spawn cmdShutdown)
    , (globalAlt,     X11T.xK_Delete,    spawn cmdRestart)
--    , (globalShift,   X11T.xK_x,         spawnMulti [cmdWMQuit, cmdExit])
--    , (globalShift,   X11T.xK_r,         spawn cmdReboot)
--    , (globalShift,   X11T.xK_s,         spawnMulti [cmdWMQuit, cmdShutdown])
--    , (global,        X11T.xK_0,         spawn cmdOneMonitor)
--    , (globalShift,   X11T.xK_0,         spawn cmdTwoMonitorsVertical)
    ] ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [(global .|. m, k, windows $ f i)
        | (i, k) <- zip workspaces [X11T.xK_1 .. X11T.xK_9]
        , (f, m) <- [(greedyView, 0), (shift, shiftMask)]]

cmdTextEditor             = "nvim" -- cmdSublime True
cmdSublime new            = "subl -w" ++ if new then " -n" else ""
cmdTerminal               = "xfce4-terminal"
cmdTerminalDropDown       = "xfce4-terminal --drop-down --title='xfce4-terminal-drop-down'"
cmdMenu                   = "xfce4-popup-whiskermenu"
cmdChromium               = "chromium-browser --new-window"
cmdFirefox                = "firefox -p $KI_USER_PROFILE"
cmdFirefoxProfiles        = "firefox -p"
cmdSessionDialog          = "xfce4-session-logout"
cmdXMonadRestart          = "xmonad --recompile && xmonad --restart"
cmdLock                   = "xflock4" --"xset s activate"
cmdLogout                 = cmdSessionDialog ++ " --logout"
cmdRestart                = cmdSessionDialog ++ " --reboot"
cmdSleep                  = cmdSessionDialog ++ " --suspend"
cmdShutdown               = cmdSessionDialog ++ " --halt"
--cmdSuspend              = "systemctl suspend"
--cmdExit                   = "killall -SIGINT xmonad-x86_64-linux"
--cmdShutdown               = "shutdown -P now"
--cmdReboot                 = "shutdown -r now"
--cmdOneMonitor             = "mon L"
--cmdTwoMonitorsVertical    = "mon a"

spawnMulti cmds = spawn $ intercalate " && " cmds

