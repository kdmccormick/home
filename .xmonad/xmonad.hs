
{- import XMonad
import XMonad.Util.Run
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Config.Xfce
import System.IO

main = do
     spawnPipe "sleep 2; xfce4-panel -r;"
     spawnPipe "synclient MaxTapTime=0"
--   spawnPipe "killall xautolock; xautolock -time 5 -locker 'xdg-screensaver lock';"
     spawnPipe "setxkbmap -option 'ctrl:nocaps'"
     xmonad $ xfceConfig
        { modMask = mod4Mask     -- Rebind Mod to the Windows key
        } `additionalKeys`
        [
          ((mod4Mask .|. shiftMask, xK_Return),        spawn "xfce4-terminal")
		, ((mod4Mask,               xK_Backspace),     spawn "xflock4")
        , ((mod4Mask .|. shiftMask, xK_Backspace),     spawn "systemctl suspend")
--      , ((mod4Mask , xK_p), spawn "rofi -show run")
--      , ((mod4Mask .|. shiftMask, xK_l), spawn "xdg-screensaver lock")
--      , ((mod4Mask, xK_c), spawn "setxkbmap -option 'ctrl:nocaps'")
        ] -}

import Control.Concurrent ( threadDelay )
import Data.List ( intercalate )
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
	X, XConfig(XConfig),
	spawn, windows, withFocused, sendMessage, kill,
	mod1Mask, mod4Mask, noModMask, shiftMask,
    (|||), (.|.), (<+>)
  )
import XMonad.Actions.SinkAll ( sinkAll )
import XMonad.Actions.SpawnOn ( spawnOn, manageSpawn )
import XMonad.Config.Xfce ( xfceConfig )
import XMonad.Hooks.EwmhDesktops
  (
    ewmh,
	ewmhDesktopsStartup, ewmhDesktopsEventHook, ewmhDesktopsLogHook,
  )
import XMonad.Hooks.ManageDocks ( manageDocks, avoidStruts )
import XMonad.Layout ( Full(Full) )
import XMonad.Layout.ResizableTile
  ( MirrorResize(MirrorExpand, MirrorShrink), ResizableTall(ResizableTall) )
import XMonad.Layout.StackTile ( StackTile(StackTile) )
import XMonad.StackSet ( focusDown, focusUp, swapDown, swapUp )
import XMonad.Util.CustomKeys ( customKeys )
import XMonad.Util.Run ( spawnPipe, runProcessWithInput )

import qualified Graphics.X11.Types as X11T

main = do
    xmonad $ xfceConfig
          { keys = customKeys delKeys insKeys
          , modMask = global
          , borderWidth = 3
		  , focusedBorderColor = "#bb00ff"
		  , normalBorderColor = "#220055"
          , terminal = cmdTerminal
		  , startupHook = onStart
          , manageHook = manageHook def <+> manageDocks <+> manageSpawn
          , layoutHook = myLayout
		  , handleEventHook = ewmhDesktopsEventHook
          , logHook    = ewmhDesktopsLogHook
          }
    where
        delKeys XConfig {modMask = modm} = unbindings
        insKeys XConfig {modMask = modm} = (
            map (\(m, k, c) -> ((m, k), c)) keybindings
          )

myLayout = avoidStruts $ tiled ||| goldenStack ||| Full
        where
          tiled        = ResizableTall nmaster delta golden []
          goldenStack  = StackTile nmaster delta golden
          golden       = toRational (2/(1 + sqrt 5 :: Double))
          nmaster      = 1 
          delta        = 0.03

onStart :: X ()
onStart =
--    spawnWks 1 (cmdSublime False)
--    spawnWks 1 cmdTerminal
--    spawnWks 2 cmdTerminal
    ewmhDesktopsStartup >>
	spawn "sleep 1; xfce4-panel"

spawnWks :: Int -> String -> X ()
spawnWks wksId cmd = spawnOn (show wksId) cmd

quitFocused :: X ()
quitFocused = withFocused  (\w -> do
        let idStr = "0x" ++ showHex w ""
        let cmd = "wmctrl -i -c " ++ idStr
        spawn cmd
    )

isRunning :: String -> X Bool
isRunning s = do
    output <- runProcessWithInput "pgrep" [s] ""
    return $ not $ null output

-- Modifier keys
noMod          = noModMask
shift          = shiftMask
alt            = mod1Mask
altShift       = alt .|. shift
super          = mod4Mask
superShift     = super .|. shift
global         = super
globalShift    = global .|. shift
globalAlt      = global .|. alt

-- Key un-bindings
unbindings =
    [ (alt, X11T.xK_VoidSymbol)  -- Don't show menu on Alt
	,  (global, X11T.xK_d)
    ]

-- Keybindings
keybindings =
    [ (global,        X11T.xK_j,         windows focusDown)
    , (global,        X11T.xK_k,         windows focusUp)
    , (globalShift,   X11T.xK_j,         windows swapDown)
    , (globalShift,   X11T.xK_k,         windows swapUp)
--    , (global,        X11T.xK_h,         sendMessage Shrink)
--    , (global,        X11T.xK_l,         sendMessage Expand)
    , (globalShift,   X11T.xK_h,         sendMessage MirrorExpand)
    , (globalShift,   X11T.xK_l,         sendMessage MirrorShrink)
    , (global,        X11T.xK_d,         kill)
    , (global,        X11T.xK_space,     spawn cmdMenu)
    , (global,        X11T.xK_Return,    spawn cmdTerminalDropDown)
    , (globalShift,   X11T.xK_Return,    spawn cmdTerminal)
    , (global,        X11T.xK_backslash, sinkAll)
--    , (globalShift,   X11T.xK_f,         spawn cmdFirefox)
--    , (globalShift,   X11T.xK_w,         spawn cmdChromium)
--    , (globalShift,   X11T.xK_e,         spawn cmdTextEditor)
    , (global,        X11T.xK_BackSpace, spawn cmdLock)
    , (globalShift,   X11T.xK_BackSpace, spawn cmdSuspend)
	, (globalAlt,     X11T.xK_BackSpace, spawn cmdSessionDialog)
--    , (globalShift,   X11T.xK_x,         spawnMulti [cmdWMQuit, cmdExit])
--    , (globalShift,   X11T.xK_r,         spawn cmdReboot)
--    , (globalShift,   X11T.xK_s,         spawnMulti [cmdWMQuit, cmdShutdown])
--    , (global,        X11T.xK_0,         spawn cmdOneMonitor)
--    , (globalShift,   X11T.xK_0,         spawn cmdTwoMonitorsVertical)
    ]

cmdTextEditor             = "nvim" -- cmdSublime True
cmdSublime new            = "subl -w" ++ if new then " -n" else ""
cmdTerminal               = "xfce4-terminal"
cmdTerminalDropDown       = "xfce4-terminal --drop-down"
cmdMenu                   = "dmenu_run"
cmdChromium               = "chromium-browser --new-window"
cmdFirefox                = "firefox"
cmdLock                   = "xflock4" --"xset s activate"
cmdSuspend                = "systemctl suspend"
cmdSessionDialog          = "xfce4-session-logout"
cmdWMQuit                 = "wmquit"
cmdExit                   = "killall -SIGINT xmonad-x86_64-linux"
cmdShutdown               = "shutdown -P now"
cmdReboot                 = "shutdown -r now"
cmdOneMonitor             = "mon L"
cmdTwoMonitorsVertical    = "mon a"

spawnMulti cmds = spawn $ intercalate " && " cmds
