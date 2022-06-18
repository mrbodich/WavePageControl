# WavePageControl

> WavePageControl allows you to effectively organise the Page Control indicators all at once.

 ## How it works

Your app has large but limited amount of pages, more than such indicators amounts could fit into most of Page Controls?\
You still want to have all indicators visible and have ability to navigate using Page Control?

 ## WavePageControl will help you

* Show all page indicators visible for a large amounts of pages (let's say `40`)
* Easily navigate through all the pages with swipe
* Quickly move to any page with just a single tap
* Clearly see the current selected page indicator among all (`40`) other
* Customise indicators!
 * Change default indicator style
 * Create your own **custom indicators**



 ## Swift Package Manager Install

 Swift Package Manager

 ```swift
 dependencies: [
     .package(url: "https://github.com/mrbodich/WavePageControl.git")
 ]
 ```


 ## CocoaPods Install

 Add `pod 'WavePageControl'` to your Podfile. "WavePageControl" is the name of the library.

 ## Help

 If you like what you see here, and want to support the work being done in this repository, you could:
 * Contribute code, issues and pull requests
 * Let people know this library exists (:rocket: spread the word :rocket:)


 ## Questions & Issues

 If you are having questions or problems, you should:

  - Make sure you are using the latest version of the library. Check the [**release-section**](https://github.com/mrbodich/WavePageControl/releases).
  - Search [**known issues**](https://github.com/mrbodich/WavePageControl/issues) for your problem (open and closed)
  - Create new issues (please :fire: **search known issues before** :fire:, do not create duplicate issues)


 # How to use

 ## Auto Layout

 Subject | Description
 --- | ---
 Position | Satisfy position layout by creating 1 horizontal and 1 vertical constraint
 Size | WavePageControl **controls size by itself**, both vertical and horizontal. So keep it in mind and avoid conflicting/ambiguous constraints

 ## Customising WavePageControl instance

 Parameter | Description
 --- | ---
 maxNavigationWidth | Maximum width of WavePageControl frame. After reaching this width, all indicators sizes will be recalculated to fit max width.
 defaultButtonHeight | Permanent height of active indicator. Other indicators will have this size until they fit into the maxNavigationWidth. Minimum size of inactive indicators is not limited.
 defaultSpacing | Spacing between indicators until they fit into the maxNavigationWidth.
 minSpacing | Once indicators start getting smaller, spacing is getting smaller too and limited with this value.
 updateLayout() | Apply changed parameters and rebuild layout. Animated by default. You can use UIView.performWithoutAnimation(_:) to eliminate animation.


 ## Using WavePageControl

 WavePageControl is utilising array of **ID**s to build page indicators.\
 WavePageControl is generic, thus `ID` can be any type until it is `Comparable`.


 Property | Description
 --- | ---
 pageIDs | Array of ids. Can be changed in any way, you don't need to think about correct arrangement. WavePageControl is smart enough to calculate all movings/insertions/removals between the previous and new state and **animate** them properly. Actually you can even put another random array here and it will just work!
 currentPage | ID of an active indicator, optional. You can put any ID here or nil. If pageIDs does not contain such ID, no any error here, WavePageControl will just indicate no selection. Once such ID will appear in pageIDs, corresponding indicator will be automatically set as active.
 delegate | Set instance conforming to WavePageControlDelegate here. `See next section for more info`


 ## Advanced Control

 You can have advanced control over the WavePageControl using the WavePageControlDelegate.
 WavePageControlDelegate has 3 methods with existing default implementation, so you can optionally implement the ones you need.

 Method | Description
 --- | ---
 createCustomPageView(id:) | Requires to return WavePageButtonView (that is UIView itself). Default implementation returns DefaultPageButtonView. `See examples in Demo Project`
 didSwipeScroll(_:, id:, isGestureCompleted:) | Called on swipe. It gives you a reference to WavePageControl, ID of indicator to select during all swipe, and a boolean state if gesture is completed. currentPage should be set explicitly here if needed. Default implementation will select it directly.
 didTap(_:, id:) | Called on tap. It gives you a reference to WavePageControl and ID of indicator to select. currentPage should be set explicitly here if needed. Default implementation will select it directly.


 # Visual Examples

 ##### Basic usage without injecting `WavePageControlDelegate`

 ![Default Example](https://user-images.githubusercontent.com/23237473/193407648-afdc083a-3f6a-4a2c-89b2-109a76daa79e.gif)

 ##### Customising `DefaultPageButtonView` in `WavePageControlDelegate`, handling `didSwipeScroll`

 ![Simple Example](https://user-images.githubusercontent.com/23237473/193407654-45683389-1b12-40ba-86f6-a4834de09540.gif)

 ##### Using fully custom `WavePageButtonView`, handling `didSwipeScroll`

 ![Custom Example](https://user-images.githubusercontent.com/23237473/193407661-ffa14672-4cd5-4748-b3df-a40803d0fafa.gif)

 ### Live usage example
 You can download the app here in the [**:point_right::iphone: App Store**](https://apps.apple.com/us/app/to-the-shop/id1542572914)

 https://user-images.githubusercontent.com/23237473/193412590-70e9b364-d60d-4cdb-9306-1e66436b722d.mp4
