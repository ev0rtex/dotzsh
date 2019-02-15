#
# Android SDK
ANDROID_SDK="$HOME/Library/Android/sdk"
[[ ":$PATH:" == *"platform-tools:"* ]] || \
    export PATH="$PATH:$ANDROID_SDK/platform-tools"
