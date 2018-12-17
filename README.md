# SunRiseSetApp

Usage instruction
1) project uses coocapods as a library manager so run pod install
2) replace YOUR_API_KEY with your Google Places API key
3) update project app ID, team and provision profile to be able to build the app

Ways to improve (can be disscussed during the interview)
1) add caching for offline usage - Reachability, Realm, small refactoring of Place class to exclude SunInfo
2) add unit testing - OHHTTPStubs for response parsing, test Date UTC to local + String formatting
3) use MVVM or even VIPER instead of simple MVC

![short demo](https://media.giphy.com/media/lISdbt9JvyrK7mYCgi/giphy.gif)
