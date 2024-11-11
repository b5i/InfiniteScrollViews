# InfiniteScrollViews

InfiniteScrollViews groups some useful SwiftUI, UIKit and AppKit components.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fb5i%2FInfiniteScrollViews%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/b5i/InfiniteScrollViews)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fb5i%2FInfiniteScrollViews%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/b5i/InfiniteScrollViews)

## A recursive logic
As we can't really generate an infinity of views and put them in a ScrollView, we need to use **a recursive logic**. The way InfiniteScrollView and PagedInfiniteScrollView can display an "infinite" amount of content works thanks to this logic:
1. You have a generic type **ChangeIndex**, it is a piece of data that the component will give you in exchange of a View/UIViewController/NSViewController.
2. When you initialize the component, it takes an argument of type **ChangeIndex** to draw its first view.
3. When the user will scroll up/down or left/right the component will give you a **ChangeIndex** but to get its "next" or "previous" value, it will use the increase and decrease actions that are provided during initialization. It will be used to draw the "next" or "previous" View/UIViewController/NSViewController with the logic in 1.
And it goes on and on indefinitely... with one exception: if you return nil when step 3. happens, it will just end the scroll and act like there's nothing more to display.
Let's see an example:
You want to draw an "infinite" calendar component like the one in the base Calendar app on iOS. All of this in SwiftUI (but it also work on UIKit and on AppKit!)

### Example
1. First let's see how we initialize the view:
   ```swift
   InfiniteScrollView(
        frame: CGRect,
        changeIndex: ChangeIndex,
        content: @escaping (ChangeIndex) -> Content,
        contentFrame: @escaping (ChangeIndex) -> CGRect,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        orientation: UIInfiniteScrollView<ChangeIndex>.Orientation, // or NSInfiniteScrollView<ChangeIndex>.Orientation
        refreshAction: ((@escaping () -> Void) -> ())? = nil,
        spacing: CGFloat = 0,
        updateBinding: Binding<Bool>? = nil
   )
   ```
   - frame: the frame of the InfiniteScrollView.
   - changeIndex: the first index that will be used to draw the view.
   - content: the query from the InfiniteScrollView to draw a View from a ChangeIndex.
   - contentFrame: the query from the InfiniteScrollView to get the frame of the View from the content query (They are separated so you can directly declare the View in the closure).
   - increaseIndexAction: the query from the InfiniteScrollView to get the value after a certain ChangeIndex (recursive logic).
   - decreaseIndexAction: the query from the InfiniteScrollView to get the value before a certain ChangeIndex (recursive logic).
   - orientation: the orientation of the InfiniteScrollView.
   - refreshAction: action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything. Gives an action that must be used in order for refresh to end.
   - spacing: space between the views.
   - updateBinding: boolean that can be changed if the InfiniteScrollView's content needs to be updated.
2. Let's see how content, increaseIndexAction and decreaseIndexAction work:
   1. For our MonthView we need to provide a Date so that it will extract the month to display.
      It could be declared like this:
      ```swift
      content: { currentDate in
          MonthView(date: currentDate)
              .padding()
      }
      ```
   2. Now let's see how increase/decrease work:
      To increase we need to get the month after the provided Date:
      ```swift
      increaseIndexAction: { currentDate in
          return Calendar.current.date(byAdding: .init(month: 1), to: currentDate)
      }
      ```
      It will add one month to the currentDate and if the operation was unsuccessful then it returns nil and the InfiniteScrollView stops.
   3. The same logic applies to the decrease action:
      ```swift
      decreaseIndexAction: { currentDate in
          return Calendar.current.date(byAdding: .init(month: -1), to: currentDate)
      }
      ```
Other examples can be found in [InfiniteScrollViewsExample](https://github.com/b5i/InfiniteScrollViewsExample).

## SwiftUI
### InfiniteScrollView
The infinite equivalent of the ScrollView component in SwiftUI.

### PagedInfiniteScrollView
The infinite equivalent of the paged TabView component in SwiftUI.

## UIKit
### UIInfiniteScrollView
The infinite equivalent of the UIScrollView component in UIKit.

### UIPagedInfiniteScrollView
A simpler version of UIPageViewController in UIKit.

## AppKit
### NSInfiniteScrollView
The infinite equivalent of the NSScrollView component in AppKit.

### NSPagedInfiniteScrollView
The infinite equivalent of the NSPageController component in AppKit.
