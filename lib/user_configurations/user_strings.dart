class UserStrings {
  //change the app_name in info.plist in ios/Runner
  /*
  * <key>CFBundleDisplayName</key>
	* <string>{app_name}</string>
  * */

  //change the app_name in Manifest.xml in android/app/src/main
  /*
  *android:label="{app_name}"
  * */
  static const app_name = 'Venit';

  static appName() {
    return app_name;
  }
}