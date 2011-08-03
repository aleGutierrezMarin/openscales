This example is intended to be run on Android
You will have to register on http://labs.adobe.com/technologies/air2/android/ and follow instructions from Developing_AIR_Apps_for_Android.pdf and AIR_Android_ReleaseNotes.pdf

To make android packages, run the following command and use "os" as password when asked
cd bin-debug
adt -package -target apk -storetype pkcs12 -keystore ../../openscales.p12 MobileTracker.apk MobileTracker-app.xml MobileTracker.swf
adb install -r MobileTracker.apk