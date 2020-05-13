
import System.Directory ( doesFileExist )
import Control.Concurrent ( threadDelay )
import Data.List ( intercalate )
import Graphics.X11.Types
import Numeric ( showHex )
import System.Process ( spawnCommand, waitForProcess, readProcessWithExitCode )
import System.Exit ( exitWith, ExitCode(..) )
import System.IO ( hPutStrLn )
import XMonad
import XMonad.Actions.KeyRemap
import XMonad.Actions.SpawnOn ( spawnOn, manageSpawn )
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops ( ewmh )
import XMonad.Util.CustomKeys
import XMonad.Util.EZConfig
import XMonad.Util.Run ( spawnPipe, runProcessWithInput )
import XMonad.Layout.ResizableTile
import XMonad.Layout.StackTile
import XMonad.Actions.SinkAll ( sinkAll )
import qualified XMonad.StackSet as W

main = do
    xmonad $ ewmh def
          { keys = customKeys delKeys insKeys
        , manageHook = manageHook def <+> manageDocks <+> manageSpawn
        , layoutHook = myLayout
        , borderWidth = 1
        , startupHook = onStart
        , terminal = cmdTerminal
        , modMask = globalMod
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
onStart = do
    spawn "~/.xmonad/start-services.sh"
    spawnWks 1 (cmdSublime False)
    spawnWks 1 cmdTerminal
    spawnWks 2 cmdTerminal
    spawnWks 3 ("test -f ~/.home_urls && cat ~/.home_urls | xargs " ++ cmdFirefox)
    spawnWks 3 ("test -f ~/.code_urls && cat ~/.code_urls | xargs " ++ cmdFirefox ++ " -P code")
    spawnWks 4 ("test -f ~/.logistics_urls && cat ~/.logistics_urls | xargs " ++ cmdFirefox ++ " -P logistics")

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
globalMod      = super
globalModShift = globalMod .|. shift

-- Key un-bindings
unbindings =
    [ (alt, xK_VoidSymbol)  -- Don't show menu on Alt
    ]

-- Keybindings
keybindings =
    [ (globalMod,        xK_u,         windows W.focusDown)
    , (globalMod,        xK_i,         windows W.focusUp)
    , (globalModShift,   xK_u,         windows W.swapDown)
    , (globalModShift,   xK_i,         windows W.swapUp)
    , (globalMod,        xK_j,         sendMessage MirrorShrink)
    , (globalMod,        xK_k,         sendMessage MirrorExpand)
    , (globalMod,        xK_x,         quitFocused)
    , (globalMod,        xK_Return,    spawn cmdMenu)
    , (globalMod,        xK_BackSpace, sinkAll)
    , (globalModShift,   xK_f,         spawn cmdFirefox)
    , (globalModShift,   xK_w,         spawn cmdChromium)
    , (globalModShift,   xK_e,         spawn cmdTextEditor)
    , (globalModShift,   xK_t,         spawn cmdTerminal)
    , (globalModShift,   xK_l,         spawn cmdLock)
    , (globalModShift,   xK_p,         spawn cmdSuspend)
    , (globalModShift,   xK_x,         spawnMulti [cmdWMQuit, cmdExit])
    , (globalModShift,   xK_r,         spawn cmdReboot)
    , (globalModShift,   xK_s,         spawnMulti [cmdWMQuit, cmdShutdown])
    , (globalModShift,   xK_m,         spawn cmdFixMouse)
    , (globalMod,        xK_0,         spawn cmdOneMonitor)
    , (globalModShift,   xK_0,         spawn cmdTwoMonitorsVertical)
    ]

cmdTextEditor             = cmdSublime True
cmdSublime new            = "subl -w" ++ if new then " -n" else ""
cmdTerminal               = "/usr/bin/x-terminal-emulator"
cmdMenu                   = "dmenu_run"
cmdChromium               = "chromium-browser --new-window"
cmdFirefox                = "firefox"
cmdLock                   = "xset s activate"
cmdSuspend                = "systemctl suspend"
cmdWMQuit                 = "wmquit"
cmdExit                   = "killall -SIGINT xmonad-x86_64-linux"
cmdShutdown               = "shutdown -P now"
cmdReboot                 = "shutdown -r now"
cmdFixMouse               = "fixmouse"
cmdOneMonitor             = "mon L"
cmdTwoMonitorsVertical    = "mon a"

spawnMulti cmds = spawn $ intercalate " && " cmds

