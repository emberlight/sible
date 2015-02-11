xcodebuild -workspace Sible.xcworkspace -configuration Release -scheme "Sible" -sdk iphoneos clean build CONFIGURATION_BUILD_DIR="./build/Release-iphoneos"
xcodebuild -workspace Sible.xcworkspace -configuration Release -scheme "Sible" -sdk iphonesimulator clean build CONFIGURATION_BUILD_DIR="./build/Release-iphonesimulator"

if [ ! -d "release" ]; then
  mkdir 'release'
fi

cp -R Sible/build/Release-iphoneos/include/**/*.h ./release/
lipo -create Sible/build/Release-iphoneos/libSible.a Sible/build/Release-iphonesimulator/libSible.a -output ./release/libSible.a
rm -rf Sible/build

