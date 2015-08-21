import XMonad.Core

main :: IO ()
main = do
	spawn "/usr/bin/firefox-bin &"
	spawn "/usr/bin/lxterminal &"
	spawn "/usr/bin/utox &"
