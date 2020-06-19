# Go to build dir
cd build

# Create package dir
mkdir -p package/addons/sourcemod/plugins
mkdir -p package/addons/sourcemod/data
mkdir -p package/addons/sourcemod/gamedata
mkdir -p package/addons/sourcemod/translations

# Copy all required stuffs to package
cp -r addons/sourcemod/plugins/AS-MicroTF2.smx package/addons/sourcemod/plugins
cp -r addons/sourcemod/plugins/AS-MicroTF2-MapChooser.smx package/addons/sourcemod/plugins
cp -r ../addons/sourcemod/data/microtf2 package/addons/sourcemod/data
cp -r ../addons/sourcemod/gamedata/microtf2.txt package/addons/sourcemod/gamedata
cp -r ../addons/sourcemod/translations package/addons/sourcemod