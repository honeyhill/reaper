sudo cp -f /Users/honeyhill/Documents/Programming/Reaper\ Scripts/reaper/Theme\ Assets/*.{ico,icns} /Applications/REAPER.app/Contents/Resources/


sudo rm -rf /var/folders/*/*/*/com.apple.dock.iconcache
sudo rm -rf /var/folders/*/*/*/com.apple.iconservices

sudo killall Dock
sudo killall Finder
sudo killall SystemUIServer
