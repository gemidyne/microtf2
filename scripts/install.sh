# Create build folder
mkdir build
cd build

# Install SourceMod
wget --input-file=http://sourcemod.net/smdrop/$SM_VERSION/sourcemod-latest-linux
tar -xzf $(cat sourcemod-latest-linux)

# Copy sp to build dir
cp -r ../addons/sourcemod/scripting addons/sourcemod
cd addons/sourcemod/scripting

# Install Dependencies
wget "https://raw.githubusercontent.com/nosoop/SM-TFEconData/master/scripting/include/tf_econ_data.inc" -O include/tf_econ_data.inc