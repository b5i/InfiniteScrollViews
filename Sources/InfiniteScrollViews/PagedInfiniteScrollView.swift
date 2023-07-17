/*
MIT License

Copyright (c) 2023 Antoine Bollengier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
//
//  PagedInfiniteScrollView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 15.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//
//  Inspired from https://gist.github.com/beader/08757070b8c8b1134ea8e53f347553d8

#if canImport(SwiftUI)
import SwiftUI
#endif
import UIKit

/// SwiftUI PagedInfiniteScrollView component.
///
/// Generic types:
/// - Content: a View.
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct PagedInfiniteScrollView<Content: View, ChangeIndex: Comparable>: UIViewControllerRepresentable {
    
    /// Data that will be passed to draw the view and get its frame.
    var changeIndex: Binding<ChangeIndex>
    
    /// Function called to get the content to display for a particular ChangeIndex.
    let content: (ChangeIndex) -> Content
    
    /// Function that get the ChangeIndex after another.
    ///
    /// Should return nil if there is no more content to display (end of the PagedScrollView at the bottom/right).
    ///
    /// For example, if ChangeIndex was Int and it meant the index of an element in an Array:
    ///
    /// ```swift
    /// let myArray: Array = [...]
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     if changeIndex < myArray.count - 1 {
    ///         return changeIndex + 1
    ///     } else {
    ///         return nil /// No more elements in the array.
    ///     }
    /// }
    /// ```
    ///
    /// Another example would be if ChangeIndex was a Date and we wanted to display every month:
    /// ```swift
    /// extension Date {
    ///     func addingXDays(x: Int) -> Date {
    ///         Calendar.current.date(byAdding: .day, value: x, to: self) ?? self
    ///     }
    /// }
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     return currentDate.addingXDays(x: 30)
    /// }
    /// ```
    let increaseIndexAction: (ChangeIndex) -> ChangeIndex?
    
    /// Function that get the ChangeIndex before another.
    ///
    /// Should return nil if there is no more content to display (end of the PagedScrollView at the top/left).
    ///
    /// For example, if ChangeIndex was Int and it meant the index of an element in an Array:
    ///
    /// ```swift
    /// let myArray: Array = [...]
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     if changeIndex > 0 {
    ///         return changeIndex - 1
    ///     } else {
    ///         return nil /// We reached the beginning of the array.
    ///     }
    /// }
    /// ```
    ///
    /// Another example would be if ChangeIndex was a Date and we wanted to display every month:
    /// ```swift
    /// extension Date {
    ///     func addingXDays(x: Int) -> Date {
    ///         Calendar.current.date(byAdding: .day, value: x, to: self) ?? self
    ///     }
    /// }
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     return currentDate.addingXDays(x: -30)
    /// }
    /// ```
    let decreaseIndexAction: (ChangeIndex) -> ChangeIndex?
    
    /// Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation.
    ///
    /// If the boolean is false (no need to animate), the direction of the animation won't be used.
    ///
    /// In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    let shouldAnimateBetween: (ChangeIndex, ChangeIndex) -> (Bool, UIPageViewController.NavigationDirection)
    
    /// The style for transitions between pages.
    let transitionStyle: UIPageViewController.TransitionStyle
    
    /// The orientation of the page-by-page navigation.
    let navigationOrientation: UIPageViewController.NavigationOrientation
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        /// Creates the main view and set it in the ``UIPageViewController``.
        let convertedClosure: (ChangeIndex) -> UIViewController = { changeIndex in
            return UIHostingController(rootView: content(changeIndex))
        }
        let changeIndexNotification: (ChangeIndex) -> () = { changeIndex in
            self.changeIndex.wrappedValue = changeIndex
        }
        let pageViewController = UIPagedInfiniteScrollView(content: convertedClosure, changeIndex: changeIndex.wrappedValue, changeIndexNotification: changeIndexNotification, increaseIndexAction: increaseIndexAction, decreaseIndexAction: decreaseIndexAction, transitionStyle: transitionStyle, navigationOrientation: navigationOrientation)
        
        let initialViewController = UIHostingController(rootView: content(changeIndex.wrappedValue))
        initialViewController.storedChangeIndex = changeIndex.wrappedValue
        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        /// Check if the view should update and if it should then it will be.
        guard let currentView = uiViewController.viewControllers?.first, let currentIndex = currentView.storedChangeIndex as? ChangeIndex else {
            return
        }
        
        let shouldAnimate: (Bool, UIPageViewController.NavigationDirection) = shouldAnimateBetween(changeIndex.wrappedValue, currentIndex)
        
        let initialViewController = UIHostingController(rootView: content(changeIndex.wrappedValue))
        initialViewController.storedChangeIndex = changeIndex.wrappedValue
        uiViewController.setViewControllers([initialViewController], direction: shouldAnimate.1, animated: shouldAnimate.0, completion: nil)
    }
}

/// UIKit component of the UIPagedInfiniteScrollView.
///
/// Generic types:
/// - Content: a View.
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
class UIPagedInfiniteScrollView<ChangeIndex>: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
    /// Data that will be passed to draw the view and get its frame.
    private var changeIndex: ChangeIndex {
        didSet {
            if let changeIndexNotification = self.changeIndexNotification {
                changeIndexNotification(changeIndex)
            }
        }
    }
    
    /// Function called when changeIndex is modified inside the class.
    ///
    /// Useful when using Bindings between mutliples UIPagedInfiniteScrollView, see a usage in ``PagedInfiniteScrollView``.
    private var changeIndexNotification: ((ChangeIndex) -> ())?
    
    /// Function called to get the content to display for a particular ChangeIndex.
    private let content: (ChangeIndex) -> UIViewController
    
    /// Function that get the ChangeIndex after another.
    ///
    /// Should return nil if there is no more content to display (end of the PagedScrollView at the bottom/right).
    ///
    /// For example, if ChangeIndex was Int and it meant the index of an element in an Array:
    ///
    /// ```swift
    /// let myArray: Array = [...]
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     if changeIndex < myArray.count - 1 {
    ///         return changeIndex + 1
    ///     } else {
    ///         return nil /// No more elements in the array.
    ///     }
    /// }
    /// ```
    ///
    /// Another example would be if ChangeIndex was a Date and we wanted to display every month:
    /// ```swift
    /// extension Date {
    ///     func addingXDays(x: Int) -> Date {
    ///         Calendar.current.date(byAdding: .day, value: x, to: self) ?? self
    ///     }
    /// }
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     return currentDate.addingXDays(x: 30)
    /// }
    /// ```
    private let increaseIndexAction: (ChangeIndex) -> ChangeIndex?
    
    /// Function that get the ChangeIndex before another.
    ///
    /// Should return nil if there is no more content to display (end of the PagedScrollView at the top/left).
    ///
    /// For example, if ChangeIndex was Int and it meant the index of an element in an Array:
    ///
    /// ```swift
    /// let myArray: Array = [...]
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     if changeIndex > 0 {
    ///         return changeIndex - 1
    ///     } else {
    ///         return nil /// We reached the beginning of the array.
    ///     }
    /// }
    /// ```
    ///
    /// Another example would be if ChangeIndex was a Date and we wanted to display every month:
    /// ```swift
    /// extension Date {
    ///     func addingXDays(x: Int) -> Date {
    ///         Calendar.current.date(byAdding: .day, value: x, to: self) ?? self
    ///     }
    /// }
    /// let increaseIndexAction: (ChangeIndex) -> ChangeIndex? = { changeIndex in
    ///     return currentDate.addingXDays(x: -30)
    /// }
    /// ```
    private let decreaseIndexAction: (ChangeIndex) -> ChangeIndex?
    
    /// Creates an instance of UIPagedInfiniteScrollView.
    /// - Parameters:
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - changeIndex: Data that will be passed to draw the view and get its frame.
    ///   - changeIndexNotification: Function called when changeIndex is modified inside the class. Useful when using Bindings between mutliples UIPagedInfiniteScrollView, see a usage in ``PagedInfiniteScrollView``.
    ///   - increaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the top/left). See definition in class to learn more.
    ///   - decreaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the bottom/right). See definition in class to learn more.
    ///   - transitionStyle: The style for transitions between pages.
    ///   - navigationOrientation: The orientation of the page-by-page navigation.
    ///
    ///  When you initialize the first view of the PagedInfiniteScrollView, don't forget to set the storedChangeIndex on your UIViewController like this:
    ///  ```swift
    ///  let myFirstChangeIndex: ChangeIndex = ...
    ///  let myViewController: UIViewController = ...
    ///  myViewController.storedChangeIndex = myFirstChangeIndex
    ///  ```
    ///  also make sure that the value you'll store in storedChangeIndex is of the type of ChangeIndex, and not `Binding<ChangingIndex>` for example, otherwise the PagedInfiniteScrollView just won't work.
    init(
        content: @escaping (ChangeIndex) -> UIViewController,
        changeIndex: ChangeIndex,
        changeIndexNotification: ((ChangeIndex) -> ())? = nil,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        transitionStyle: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation
    ) {
        let convertedClosure: (ChangeIndex) -> UIViewController = { changeIndex in
            let controller = content(changeIndex)
            controller.storedChangeIndex = changeIndex
            return controller
        }
        self.content = convertedClosure
        self.changeIndex = changeIndex
        self.changeIndexNotification = changeIndexNotification
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        super.init(transitionStyle: transitionStyle, navigationOrientation: navigationOrientation)
        self.dataSource = self
        self.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, please open a PR if you would like it to be implemented")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewController.storedChangeIndex as? ChangeIndex else {
            return nil /// Stops scroll.
        }
        
        /// Check if there is more content to display, if yes then it returns it.
        if let decreasedIndex = decreaseIndexAction(currentIndex) {
            return content(decreasedIndex)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewController.storedChangeIndex as? ChangeIndex else {
            return nil /// Stops scroll.
        }

        /// Check if there is more content to display, if yes then it returns it.
        if let increasedIndex = increaseIndexAction(currentIndex) {
            return content(increasedIndex)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        /// Check if the transition was successful and update the changeIndex of the class.
        if completed,
           let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = currentViewController.storedChangeIndex as? ChangeIndex {
            changeIndex = currentIndex
        }
    }
}

/// To store the changeIndex in the ViewController
///
/// From: https://tetontech.wordpress.com/2015/11/12/adding-custom-class-properties-with-swift-extensions/
public extension UIViewController {
    private struct ChangeIndex {
        static var changeIndex: Any? = nil
    }
    
    var storedChangeIndex: Any? {
        get {
            return objc_getAssociatedObject(self, &ChangeIndex.changeIndex) as Any?
        }
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &ChangeIndex.changeIndex, unwrappedValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
