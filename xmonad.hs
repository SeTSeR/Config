import System.IO
import XMonad
import XMonad.ManageHook
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.Mosaic
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Util.Run
import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W
import qualified Data.Map as M

xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"

defaults = defaultConfig {
          terminal             = "lxterminal"
	, workspaces           = myWorkspaces
	, modMask              = mod1Mask
	, layoutHook           = myLayoutHook
	, manageHook           = myManageHook
	, handleEventHook      = fullscreenEventHook  -- для корректного отображения окон в полно экранном режиме
	, startupHook          = setWMName "LG3D"  -- для совместимости определёных приложений, java например(IntelliJ IDEA)
	, borderWidth          = 2
	, normalBorderColor    = "black"
	, focusedBorderColor  = "orange"   
}

myManageHook :: ManageHook
myManageHook = composeAll . concat $
    [ [className =? c --> doF (W.shift "web")		| c <- myWeb]
    , [className =? c --> doF (W.shift "dev")		| c <- myDev]
    , [className =? c --> doF (W.shift "term")	        | c <- myTerm]
    , [className =? c --> doF (W.shift "vm")		| c <- myVMs]
    , [className =? c --> doF (W.shift "utox")		| c <- myUtox]
    , [className =? c --> doF (W.shift "games")		| c <- myGames]
    , [manageDocks]
    ]
    where
	myWeb = ["Firefox","Chromium","Chrome"]
	myDev = ["Eclipse","Gedit","sublime-text","gvim","yi"]
	myTerm = ["Terminator","xterm","urxvt","lxterminal"]
	myVMs = ["VirtualBox","qemu-system-i386"]
	myUtox = ["utox"]
	myGames = ["xmoto"]

myWorkspaces :: [String]
myWorkspaces =  ["web","dev","term","vm","media","utox","games"] ++ map show [7..10]

myTabConfig = defaultTheme {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

myLayoutHook = spacing 6 $ gaps [(U,15)] $ toggleLayouts (noBorders Full) $ smartBorders $ Mirror tiled ||| mosaic 2 [3,2]  ||| tabbed shrinkText myTabConfig
    where 
	tiled = Tall nmaster delta ratio
	nmaster = 1
	delta   = 3/100
	ratio   = 3/5

main :: IO ()
main = do
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobar.hs"
    spawn "~/.xmonad/autostart"
    xmonad $ defaults {
	          logHook =  dynamicLogWithPP $ defaultPP {
			  ppOutput = hPutStrLn xmproc
	        	, ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
	  		, ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
			, ppSep = "   "
			, ppWsSep = " "
			, ppLayout  = (\ x -> case x of
				"Spacing 6 Mosaic"                      -> "[:]"
				"Spacing 6 Mirror Tall"                 -> "[M]"
				"Spacing 6 Hinted Tabbed Simplest"      -> "[T]"
				"Spacing 6 Full"                        -> "[ ]"
				_                                       -> x )
			, ppHiddenNoWindows = showNamedWorkspaces
		  } 
    } where showNamedWorkspaces wsId = if any (`elem` wsId) ['a'..'z']
                                       then pad wsId
				       else ""
