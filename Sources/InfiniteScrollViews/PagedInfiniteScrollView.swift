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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI PagedInfiniteScrollView component.
///
/// Generic types:
/// - Content: a View.
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct PagedInfiniteScrollView<Content: View, ChangeIndex> {
    
    /// Data that will be passed to draw the view and get its frame.
    public var changeIndex: Binding<ChangeIndex>
    
    /// Function called to get the content to display for a particular ChangeIndex.
    public let content: (ChangeIndex) -> Content
    
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
    public let increaseIndexAction: (ChangeIndex) -> ChangeIndex?
    
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
    public let decreaseIndexAction: (ChangeIndex) -> ChangeIndex?
    
    
    #if os(macOS)
    /// Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation. If the boolean is false (no need to animate), the direction of the animation won't be used. In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    public let shouldAnimateBetween: (_ oldIndex: ChangeIndex, _ newIndex: ChangeIndex) -> (Bool, NSPagedInfiniteScrollView<ChangeIndex>.SlideSide)
    /// Function that should tell whether two ChangeIndex should be considered as equal (and so shouldn't change the controller if a transition is made between them).
    public let indexesEqual: (ChangeIndex, ChangeIndex) -> Bool
    
    /// The style for transitions between pages.
    public let transitionStyle: NSPageController.TransitionStyle
    
    /// Creates a new instance of PagedInfiniteScrollView.
    /// - Parameters:
    ///   - changeIndex: Data that will be passed to draw the view and get its frame.
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - increaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the top/left). See definition in class to learn more.
    ///   - decreaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the bottom/right). See definition in class to learn more.
    ///   - shouldAnimateBetween: Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation. If the boolean is false (no need to animate), the direction of the animation won't be used. In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    ///   - indexesEqual: Function that should tell whether two ChangeIndex should be considered as equal (and so shouldn't change the controller if a transition is made between them).
    ///   - transitionStyle: The style for transitions between pages.
    public init(
        changeIndex: Binding<ChangeIndex>,
        content: @escaping (ChangeIndex) -> Content,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        shouldAnimateBetween: @escaping (_ oldIndex: ChangeIndex, _ newIndex: ChangeIndex) -> (Bool, NSPagedInfiniteScrollView<ChangeIndex>.SlideSide),
        indexesEqual: @escaping (ChangeIndex, ChangeIndex) -> Bool,
        transitionStyle: NSPageController.TransitionStyle = .horizontalStrip
    ) {
        self.changeIndex = changeIndex
        self.content = content
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        self.shouldAnimateBetween = shouldAnimateBetween
        self.indexesEqual = indexesEqual
        self.transitionStyle = transitionStyle
    }
    
    public func makeNSViewController(context: Context) -> NSPagedInfiniteScrollView<ChangeIndex> {
        /// Creates the main view and set it in the ``NSPageViewController``.
        let convertedClosure: (ChangeIndex) -> NSViewController = { changeIndex in
            return NSHostingController(rootView: content(changeIndex))
        }
        let changeIndexNotification: (ChangeIndex) -> () = { changeIndex in
            DispatchQueue.main.async {
                self.changeIndex.wrappedValue = changeIndex
            }
        }
        
        return NSPagedInfiniteScrollView(content: convertedClosure, changeIndex: changeIndex.wrappedValue, changeIndexNotification: changeIndexNotification, increaseIndexAction: increaseIndexAction, decreaseIndexAction: decreaseIndexAction, shouldAnimateBetween: shouldAnimateBetween, indexesEqual: indexesEqual, transitionStyle: transitionStyle)
    }
    
    public func updateNSViewController(_ nsViewController: NSPagedInfiniteScrollView<ChangeIndex>, context: Context) {
        nsViewController.changeCurrentIndex(to: changeIndex.wrappedValue)
    }
    #else
    
    /// Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation.
    ///
    /// If the boolean is false (no need to animate), the direction of the animation won't be used.
    ///
    /// In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    public let shouldAnimateBetween: (ChangeIndex, ChangeIndex) -> (Bool, UIPageViewController.NavigationDirection)
    
    /// The style for transitions between pages.
    public let transitionStyle: UIPageViewController.TransitionStyle
    
    /// The orientation of the page-by-page navigation.
    public let navigationOrientation: UIPageViewController.NavigationOrientation
    
    /// Creates a new instance of PagedInfiniteScrollView.
    /// - Parameters:
    ///   - changeIndex: Data that will be passed to draw the view and get its frame.
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - increaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the top/left). See definition in class to learn more.
    ///   - decreaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the bottom/right). See definition in class to learn more.
    ///   - shouldAnimateBetween: Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation. If the boolean is false (no need to animate), the direction of the animation won't be used. In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    ///   - transitionStyle: The style for transitions between pages.
    ///   - navigationOrientation: The orientation of the page-by-page navigation.
    public init(
        changeIndex: Binding<ChangeIndex>,
        content: @escaping (ChangeIndex) -> Content,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        shouldAnimateBetween: @escaping (ChangeIndex, ChangeIndex) -> (Bool, UIPageViewController.NavigationDirection),
        transitionStyle: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation
    ) {
        self.changeIndex = changeIndex
        self.content = content
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        self.shouldAnimateBetween = shouldAnimateBetween
        self.transitionStyle = transitionStyle
        self.navigationOrientation = navigationOrientation
    }
    
    public func makeUIViewController(context: Context) -> UIPageViewController {
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
    
    public func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        /// Check if the view should update and if it should then it will be.
        guard let currentView = uiViewController.viewControllers?.first, let currentIndex = currentView.storedChangeIndex as? ChangeIndex else {
            return
        }
        
        let shouldAnimate: (Bool, UIPageViewController.NavigationDirection) = shouldAnimateBetween(changeIndex.wrappedValue, currentIndex)
        
        let initialViewController = UIHostingController(rootView: content(changeIndex.wrappedValue))
        initialViewController.storedChangeIndex = changeIndex.wrappedValue
        uiViewController.setViewControllers([initialViewController], direction: shouldAnimate.1, animated: shouldAnimate.0, completion: nil)
    }
    
    #endif
}

#if os(macOS)
extension PagedInfiniteScrollView: NSViewControllerRepresentable {}
#else
extension PagedInfiniteScrollView: UIViewControllerRepresentable {}
#endif

#endif // canImport(SwiftUI)

#if os(macOS)

public class NSPagedInfiniteScrollView<ChangeIndex>: NSPageController, NSPageControllerDelegate {
    
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
    private let content: (ChangeIndex) -> NSViewController
    
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
    
    /// Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation. If the boolean is false (no need to animate), the direction of the animation won't be used. In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    private let shouldAnimateBetween: (_ oldIndex: ChangeIndex, _ newIndex: ChangeIndex) -> (shouldAnimate: Bool, side: SlideSide)
    
    private let indexesEqual: (ChangeIndex, ChangeIndex) -> Bool
    
    private var indexForString: [String: ChangeIndex] = [:]
        
    /// Creates an instance of NSPagedInfiniteScrollView.
    /// - Parameters:
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - changeIndex: Data that will be passed to draw the view and get its frame.
    ///   - changeIndexNotification: Function called when changeIndex is modified inside the class. Useful when using Bindings between mutliples NSPagedInfiniteScrollView, see a usage in ``PagedInfiniteScrollView``.
    ///   - increaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the top/left). See definition in class to learn more.
    ///   - decreaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the PagedScrollView at the bottom/right). See definition in class to learn more.
    ///   - shouldAnimateBetween: Function that will return a boolean indicating if there's need to animate the change between two given ChangeIndex, it also returns the direction of the animation. If the boolean is false (no need to animate), the direction of the animation won't be used. In most of the cases you won't want to animate if the two values are equals because it would animate barely everytime during the app use.
    ///   - indexesEqual: Function that should tell whether two ChangeIndex should be considered as equal (and so shouldn't change the controller if a transition is made between them).
    ///   - transitionStyle: The style for transitions between pages.
    public init(
        content: @escaping (ChangeIndex) -> NSViewController,
        changeIndex: ChangeIndex,
        changeIndexNotification: ((ChangeIndex) -> ())? = nil,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        shouldAnimateBetween: @escaping (ChangeIndex, ChangeIndex) -> (Bool, SlideSide),
        indexesEqual: @escaping (ChangeIndex, ChangeIndex) -> Bool,
        transitionStyle: NSPageController.TransitionStyle = .horizontalStrip
    ) {
        self.content = content
        self.changeIndex = changeIndex
        self.changeIndexNotification = changeIndexNotification
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        self.shouldAnimateBetween = shouldAnimateBetween
        self.indexesEqual = indexesEqual
        super.init(nibName: nil, bundle: nil)
        self.transitionStyle = transitionStyle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // setDontCacheViewControllers:, as we always create new controllers, we don't want to store them.
        let selectorEncodedString = "c2V0RG9udENhY2hlVmlld0NvbnRyb2xsZXJzOg=="
        let selectorEncodedData = Data(base64Encoded: selectorEncodedString)!
        self.perform(Selector(String(decoding: selectorEncodedData, as: UTF8.self)), with: true)
                
        // Set up NSPageController
        self.delegate = self
        
        self.selectedIndex = 0
        
        self.arrangedObjects.append(changeIndex)
        
        if let previousIndex = decreaseIndexAction(self.changeIndex) {
            self.arrangedObjects.insert(previousIndex, at: 0)
            self.selectedIndex = 1
        }
                
        if let nextIndex = increaseIndexAction(self.changeIndex) {
            self.arrangedObjects.append(nextIndex)
        }
    
        self.view.autoresizingMask = [.width, .height]
    }
    
    /// Boolean indicating whether an animation is currently running.
    private var isAnimating: Bool = false
    
    /// Programmaticaly change the current index (with animation).
    public func changeCurrentIndex(to newIndex: ChangeIndex) {
        if !self.indexesEqual(self.changeIndex, newIndex) {
            if let newIndexIndex = self.arrangedObjects.firstIndex(where: {
                if let index = ($0 as? ChangeIndex) {
                    return self.indexesEqual(index, newIndex)
                } else {
                    return false
                }
            }) {
                let potentialAnimation = self.shouldAnimateBetween(self.changeIndex, newIndex)
                if potentialAnimation.shouldAnimate {
                    NSAnimationContext.runAnimationGroup { _ in
                        self.animator().selectedIndex = newIndexIndex
                    } completionHandler: {
                        self.completeTransition()
                    }
                } else {
                    self.completeTransition()
                    self.selectedIndex = newIndexIndex
                }
                return
            }
            let potentialAnimation = self.shouldAnimateBetween(self.changeIndex, newIndex)
            
            switch potentialAnimation.side {
            case .trailing:
                self.arrangedObjects.insert(newIndex, at: 0)
                if potentialAnimation.shouldAnimate {
                    //To animate a selectedIndex change:
                    NSAnimationContext.runAnimationGroup { _ in
                        self.animator().selectedIndex = 0
                    } completionHandler: {
                        self.completeTransition()
                    }
                } else {
                    self.completeTransition()
                    self.selectedIndex = 0
                }
            case .leading:
                self.arrangedObjects.append(newIndex)
                if potentialAnimation.shouldAnimate {
                    //To animate a selectedIndex change:
                    NSAnimationContext.runAnimationGroup { _ in
                        self.isAnimating = true
                        // go to the last element so the animation is going to the leading side
                        self.animator().selectedIndex = self.arrangedObjects.count - 1
                    } completionHandler: {
                        self.completeTransition()
                        self.isAnimating = false

                        if let nextIndex = self.increaseIndexAction(self.changeIndex) {
                            self.arrangedObjects.append(nextIndex)
                        }
                    }
                } else {
                    self.completeTransition()
                    self.selectedIndex = self.arrangedObjects.count - 1
                }
            }
        }
    }

    public func pageController(_ pageController: NSPageController, identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        guard let index = object as? ChangeIndex else { return "" }
            
        // Use a unique identifier for each page
        if let indexString = self.indexForString.first(where: {
            self.indexesEqual($0.value, index)
        })?.key {
            return indexString
        } else {
            let indexString = UUID().uuidString
            
            self.indexForString[indexString] = index
            
            return indexString
        }
    }

    public func pageController(_ pageController: NSPageController, viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        guard let index = self.indexForString[identifier] else { return NSViewController() }
        
        return self.content(index)
    }

    /// Logic:
    /// 1. Take the new index
    /// 2. Take a potential previous index, put it in the ``NSPagedInfiniteScrollView/arrangedObjects`` before the new index. If there isn't, put only the new index in the ``NSPagedInfiniteScrollView/arrangedObjects``.
    /// 3. Check if there's a nextIndex, if there is, put it at the end of ``NSPagedInfiniteScrollView/arrangedObjects``.
    public func pageController(_ pageController: NSPageController, didTransitionTo object: Any) {
        
        guard let newIndex = object as? ChangeIndex else { return }
        
        self.changeIndex = newIndex
        
        NSAnimationContext.beginGrouping()
                
        NSAnimationContext.current.allowsImplicitAnimation = false
        
        if self.selectedIndex == 0 {
            self.arrangedObjects = [newIndex]
            
            if let nextIndex = increaseIndexAction(self.changeIndex) {
                self.arrangedObjects.append(nextIndex)
            }
            
            if let previousIndex = decreaseIndexAction(self.changeIndex) {
                self.arrangedObjects.insert(previousIndex, at: 0)
                self.selectedIndex = 1
            }
        } else if self.selectedIndex > 1 && !self.isAnimating {
            // keep the second and third element
            if let previousIndex = decreaseIndexAction(self.changeIndex) {
                self.arrangedObjects = [previousIndex, self.changeIndex]
                self.selectedIndex = 1
            } else {
                self.arrangedObjects = [self.changeIndex]
            }
            
            if let nextIndex = increaseIndexAction(self.changeIndex) {
                self.arrangedObjects.append(nextIndex)
            }
        }
                
        NSAnimationContext.endGrouping()
        
        self.removeUnusedIndexes()
    }
    
    private func removeUnusedIndexes() {
        self.indexForString = self.indexForString.filter { element in
            self.arrangedObjects.contains {
                if let index = ($0 as? ChangeIndex) {
                    return self.indexesEqual(index, element.value)
                } else {
                    return false
                }
            }
        }
    }
    
    public enum SlideSide {
        case leading, trailing
    }
}
#else
/// UIKit component of the UIPagedInfiniteScrollView.
///
/// Generic types:
/// - Content: a View.
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
public class UIPagedInfiniteScrollView<ChangeIndex>: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
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
    public init(
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
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewController.storedChangeIndex as? ChangeIndex else {
            return nil /// Stops scroll.
        }
        
        /// Check if there is more content to display, if yes then it returns it.
        if let decreasedIndex = decreaseIndexAction(currentIndex) {
            return content(decreasedIndex)
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewController.storedChangeIndex as? ChangeIndex else {
            return nil /// Stops scroll.
        }

        /// Check if there is more content to display, if yes then it returns it.
        if let increasedIndex = increaseIndexAction(currentIndex) {
            return content(increasedIndex)
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
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
#endif
