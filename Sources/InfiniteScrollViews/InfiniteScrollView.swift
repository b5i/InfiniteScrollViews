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
//  InfiniteScrollView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 14.07.2023.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//
// Work inspired by https://developer.apple.com/library/archive/samplecode/StreetScroller/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011102-Intro-DontLinkElementID_2

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI InfiniteScrollView component.
///
/// Generic types:
/// - Content: a View.
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InfiniteScrollView<Content: View, ChangeIndex> {
    #if os(macOS)
    public typealias NSViewType = NSInfiniteScrollView
    public typealias Orientation = NSInfiniteScrollView<ChangeIndex>.Orientation
    #else
    public typealias UIViewType = UIInfiniteScrollView
    public typealias Orientation = UIInfiniteScrollView<ChangeIndex>.Orientation
    #endif
    
    /// Frame of the view.
    public let frame: CGRect
    
    /// Data that will be passed to draw the view and get its frame.
    public var changeIndex: ChangeIndex
    
    /// Function called to get the content to display for a particular ChangeIndex.
    public let content: (ChangeIndex) -> Content
    
    /// The frame of the content to be displayed.
    public let contentFrame: (ChangeIndex) -> CGRect
    
    /// Function that get the ChangeIndex after another.
    ///
    /// Should return nil if there is no more content to display (end of the ScrollView at the bottom/right).
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
    /// Should return nil if there is no more content to display (end of the ScrollView at the top/left).
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
    
    /// Orientation of the ScrollView
    public let orientation: Orientation
    
    /// Action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything.
    ///
    /// Gives an action that must be used in order for refresh to end.
    public let refreshAction: ((@escaping () -> Void) -> ())?
    
    /// Space between the views.
    public let spacing: CGFloat
    
    /// Number that will be used to multiply to the view frame height/width so it can scroll.
    ///
    /// Can be used to reduce high-speed scroll lag, set it higher if you need to increment the maximum scroll speed.
    public let contentMultiplier: CGFloat
    
    /// Boolean that can be changed if the InfiniteScrollView's content needs to be updated.
    public var updateBinding: Binding<Bool>?
    
    /// Creates a new instance of InfiniteScrollView
    /// - Parameters:
    ///   - frame: Frame of the view.
    ///   - changeIndex: Data that will be passed to draw the view and get its frame.
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - contentFrame: The frame of the content to be displayed.
    ///   - increaseIndexAction: Function that get the ChangeIndex after another. Should return nil if there is no more content to display (end of the ScrollView at the bottom/right).
    ///   - decreaseIndexAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the ScrollView at the top/left).
    ///   - orientation: Orientation of the ScrollView.
    ///   - refreshAction: Action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything. Gives an action that must be used in order for refresh to end.
    ///   - spacing: Space between the views.
    ///   - contentMultiplier: Number that will be used to multiply to the view frame height/width so it can scroll. Can be used to reduce high-speed scroll lag, set it higher if you need to increment the maximum scroll speed.
    ///   - updateBinding: Boolean that can be changed if the InfiniteScrollView's content needs to be updated.
    public init(
        frame: CGRect,
        changeIndex: ChangeIndex,
        content: @escaping (ChangeIndex) -> Content,
        contentFrame: @escaping (ChangeIndex) -> CGRect,
        increaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        decreaseIndexAction: @escaping (ChangeIndex) -> ChangeIndex?,
        orientation: Orientation,
        refreshAction: ((@escaping () -> Void) -> ())? = nil,
        spacing: CGFloat = 0,
        contentMultiplier: CGFloat = 6,
        updateBinding: Binding<Bool>? = nil
    ) {
        self.frame = frame
        self.changeIndex = changeIndex
        self.content = content
        self.contentFrame = contentFrame
        self.increaseIndexAction = increaseIndexAction
        self.decreaseIndexAction = decreaseIndexAction
        self.orientation = orientation
        self.refreshAction = refreshAction
        self.spacing = spacing
        self.contentMultiplier = contentMultiplier
        self.updateBinding = updateBinding
    }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> NSInfiniteScrollView<ChangeIndex> {
        let convertedClosure: (ChangeIndex) -> NSView = { changeIndex in
            return NSHostingController(rootView: content(changeIndex)).view
        }
        return NSInfiniteScrollView(
            frame: frame,
            content: convertedClosure,
            contentFrame: contentFrame,
            changeIndex: changeIndex,
            changeIndexIncreaseAction: increaseIndexAction,
            changeIndexDecreaseAction: decreaseIndexAction,
            contentMultiplier: contentMultiplier,
            orientation: orientation,
            refreshAction: refreshAction,
            spacing: spacing
        )
    }
    
    public func updateNSView(_ nsView: NSInfiniteScrollView<ChangeIndex>, context: Context) {
        if updateBinding?.wrappedValue ?? false {
            nsView.layout()
            if !Thread.isMainThread {
                DispatchQueue.main.sync {
                    updateBinding?.wrappedValue = false
                }
            } else {
                updateBinding?.wrappedValue = false
            }
        }
    }
    #else
    public func makeUIView(context: Context) -> UIInfiniteScrollView<ChangeIndex> {
        let convertedClosure: (ChangeIndex) -> UIView = { changeIndex in
            return UIHostingController(rootView: content(changeIndex)).view
        }
        return UIInfiniteScrollView(
            frame: frame,
            content: convertedClosure,
            contentFrame: contentFrame,
            changeIndex: changeIndex,
            changeIndexIncreaseAction: increaseIndexAction,
            changeIndexDecreaseAction: decreaseIndexAction,
            contentMultiplier: contentMultiplier,
            orientation: orientation,
            refreshAction: refreshAction,
            spacing: spacing
        )
    }
    
    public func updateUIView(_ uiView: UIInfiniteScrollView<ChangeIndex>, context: Context) {
        if updateBinding?.wrappedValue ?? false {
            uiView.layoutSubviews()
            updateBinding?.wrappedValue = false
        }
    }
    #endif
}
#endif
    
#if os(macOS)
extension InfiniteScrollView: NSViewRepresentable {}
#else
extension InfiniteScrollView: UIViewRepresentable {}
#endif

#if os(macOS)
import AppKit

/// AppKit component of the InfiniteScrollView.
///
/// Generic types:
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
public class NSInfiniteScrollView<ChangeIndex>: NSScrollView {
    
    /// Number that will be used to multiply to the view frame height/width so it can scroll.
    ///
    /// Can be used to reduce high-speed scroll lag, set it higher if you need to increment the maximum scroll speed.
    private var contentMultiplier: CGFloat
    
    /// Data that will be passed to draw the view and get its frame.
    private var changeIndex: ChangeIndex
    
    /// Function called to get the content to display for a particular ChangeIndex.
    private let content: (ChangeIndex) -> NSView
    
    /// The frame of the content to be displayed.
    private let contentFrame: (ChangeIndex) -> CGRect
    
    /// Function that get the ChangeIndex after another.
    ///
    /// Should return nil if there is no more content to display (end of the ScrollView at the bottom/right).
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
    private let changeIndexIncreaseAction: (ChangeIndex) -> ChangeIndex?
    
    /// Function that get the ChangeIndex before another.
    ///
    /// Should return nil if there is no more content to display (end of the ScrollView at the top/left).
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
    private let changeIndexDecreaseAction: (ChangeIndex) -> ChangeIndex?
    
    /// Orientation of the ScrollView.
    private let orientation: Orientation
    
    /// Action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything.
    ///
    /// Gives an action that must be used in order for refresh to end.
    public let refreshAction: ((@escaping () -> Void) -> ())?
    
    /// Space between the views.
    private let spacing: CGFloat
    
    /// Array containing the displayed views and their associated data.
    private var visibleLabels: [(NSView, ChangeIndex)]
    
    /// A integer indicating whether the NSInfiniteScrollView is doing the layout. Used to prevent infinite recursion when moving the scrollView's offset.
    private var sameTimeLayout: Int = 0
        
    /// Creates an instance of UIInfiniteScrollView.
    /// - Parameters:
    ///   - frame: Frame of the view.
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - contentFrame: The frame of the content to be displayed.
    ///   - changeIndex: Data that will be passed to draw the view and get its frame, for the first view that will be displayed at init.
    ///   - changeIndexIncreaseAction: Function that get the ChangeIndex after another. Should return nil if there is no more content to display (end of the ScrollView at the bottom/right).
    ///   - changeIndexDecreaseAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the ScrollView at the top/left).
    ///   - contentMultiplier: Number that will be used to multiply to the view frame height/width so it can scroll. Can be used to reduce high-speed scroll lag, set it higher if you need to increment the maximum scroll speed.
    ///   - orientation: Orientation of the ScrollView.
    ///   - refreshAction: Action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything. Gives an action that must be used in order for refresh to end.
    ///   - spacing: Space between the views.
    public init(
        frame: CGRect,
        content: @escaping (ChangeIndex) -> NSView,
        contentFrame: @escaping (ChangeIndex) -> CGRect,
        changeIndex: ChangeIndex,
        changeIndexIncreaseAction: @escaping (ChangeIndex) -> ChangeIndex?,
        changeIndexDecreaseAction: @escaping (ChangeIndex) -> ChangeIndex?,
        contentMultiplier: CGFloat = 6,
        orientation: Orientation,
        refreshAction: ((@escaping () -> Void) -> ())?,
        spacing: CGFloat = 0
    ) {
        self.visibleLabels = []
        self.content = content
        self.contentFrame = contentFrame
        self.changeIndex = changeIndex
        self.changeIndexIncreaseAction = changeIndexIncreaseAction
        self.changeIndexDecreaseAction = changeIndexDecreaseAction
        self.contentMultiplier = contentMultiplier
        self.orientation = orientation
        self.refreshAction = refreshAction
        self.spacing = spacing
        super.init(frame: frame)
    
        self.documentView = NSView(frame: frame)
        
        /// Increase the size of the ScrollView orientation for the view to be scrollable.
        switch orientation {
        case .horizontal:
            self.documentSize = CGSizeMake(self.frame.size.width * self.contentMultiplier, self.frame.size.height)
        case .vertical:
            self.documentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * self.contentMultiplier)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.hasVerticalScroller = false
        self.hasHorizontalScroller = false
        
        self.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(layout), name: NSView.boundsDidChangeNotification, object: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, please open a PR if you would like it to be implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Recenter content periodically to achieve impression of infinite scrolling
    private func recenterIfNecessary(beforeIndexUndefined: Bool, afterIndexUndefined: Bool) {
        switch orientation {
        case .horizontal:
            let currentOffset: CGPoint = self.documentOffset
            let contentWidth: CGFloat = self.documentSize.width
            let centerOffsetX: CGFloat = (contentWidth - self.bounds.size.width) / 2
            let distanceFromCenter: CGFloat = abs(currentOffset.x - centerOffsetX)
            
            if beforeIndexUndefined {
                self.goLeft()
            } else if afterIndexUndefined {
                self.goRight()
            } else {
                if distanceFromCenter > (contentWidth / contentMultiplier) {
                    self.documentOffset = CGPointMake(centerOffsetX, currentOffset.y)
                    
                    /// Move content by the same amount so it appears to stay still.
                    for (label, _) in self.visibleLabels {
                        var center: CGPoint = self.convert(label.center, to: self)
                        center.x += (centerOffsetX - currentOffset.x)
                        label.center = self.convert(center, to: self)
                    }
                }
            }
        case .vertical:
            let currentOffset: CGPoint = self.documentOffset
            let contentHeight: CGFloat = self.documentSize.height
            let centerOffsetY: CGFloat = (contentHeight - self.bounds.size.height) / 2
            let distanceFromCenter: CGFloat = abs(currentOffset.y - centerOffsetY)
            
            if beforeIndexUndefined {
                self.goUp()
            } else if afterIndexUndefined {
                self.goDown()
            } else {
                if distanceFromCenter > (contentHeight / contentMultiplier) {
                    self.documentOffset = CGPointMake(currentOffset.x, centerOffsetY)
                    
                    /// Move content by the same amount so it appears to stay still.
                    for (label, _) in self.visibleLabels {
                        var center: CGPoint = self.convert(label.center, to: self)
                        center.y += (centerOffsetY - currentOffset.y)
                        label.center = self.convert(center, to: self)
                    }
                }
            }
        }
    }
    
    /// Recenter all the views to the top.
    private func goUp() {
        /// Move content by the same amount so it appears to stay still.
        var pointsFromTop: CGFloat = 0
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels {
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            if !changedMainOffset {
                self.documentOffset.y -= origin.y
                changedMainOffset = true
            }
            origin.y = pointsFromTop
            label.frame.origin = self.convert(origin, to: self)
            pointsFromTop += label.frame.height + spacing
        }
    }
    
    /// Recenter all the views to the left.
    private func goLeft() {
        /// Move content by the same amount so it appears to stay still.
        var pointsFromLeft: CGFloat = 0
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels {
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            origin.x = pointsFromLeft
            if !changedMainOffset {
                self.documentOffset.x -= origin.x
                changedMainOffset = true
            }
            label.frame.origin = self.convert(origin, to: self)
            pointsFromLeft += label.frame.width + spacing
        }
    }
    
    /// Recenter all the views to the bottom.
    private func goDown() {
        /// Move content by the same amount so it appears to stay still.
        var pointsToTop: CGFloat = self.documentSize.height
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels.reversed() {
            pointsToTop -= label.frame.height
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            if !changedMainOffset {
                self.documentOffset.y += pointsToTop - origin.y
                changedMainOffset = true
            }
            origin.y = pointsToTop
            label.frame.origin = self.convert(origin, to: self)
            pointsToTop -= spacing
        }
    }
    
    /// Recenter all the views to the right.
    private func goRight() {
        /// Move content by the same amount so it appears to stay still.
        var pointsToLeft: CGFloat = self.documentSize.width
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels.reversed() {
            pointsToLeft -= label.frame.width
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            if !changedMainOffset {
                self.documentOffset.x += pointsToLeft - origin.x
                changedMainOffset = true
            }
            origin.x = pointsToLeft
            label.frame.origin = self.convert(origin, to: self)
            pointsToLeft -= spacing
        }
    }
        
    public override func layout() {
        super.layout()
        self.sameTimeLayout += 1
        /// Get the before and after indexes.
        let beforeIndex = {
            if let firstchangeIndex = self.visibleLabels.first {
                return self.changeIndexDecreaseAction(firstchangeIndex.1)
            } else {
                /// No view in visibleLabels, need to create one with the current changeIndex
                return self.changeIndexDecreaseAction(self.changeIndex)
            }
        }()
        let afterIndex = {
            if let lastchangeIndex = self.visibleLabels.last {
                return self.changeIndexIncreaseAction(lastchangeIndex.1)
            } else {
                /// No view in visibleLabels, need to create one with the current changeIndex
                return self.changeIndexIncreaseAction(self.changeIndex)
            }
        }()
        /// Checks whether the content to display takes less than the height/width of the screen (in that case it will reduce the size of the frame to avoid all the recentering/resizing operations).
        let isLittle =
        (orientation == .horizontal && (self.visibleLabels.last?.0.frame.origin.x ?? 0) + (self.visibleLabels.last?.0.frame.width ?? 0) - (self.visibleLabels.first?.0.frame.origin.x ?? 0) < self.frame.size.width + 1)
        ||
        (orientation == .vertical && (self.visibleLabels.last?.0.frame.origin.y ?? 0) + (self.visibleLabels.last?.0.frame.height ?? 0) - (self.visibleLabels.first?.0.frame.origin.y ?? 0) < self.frame.size.height + 1)

        if beforeIndex == nil && afterIndex == nil, isLittle {
            switch orientation {
            case .horizontal:
                self.documentSize = CGSizeMake(self.frame.size.width + 1, self.frame.size.height) // Add one to make it scrollable.
                self.goLeft()
            case .vertical:
                self.documentSize = CGSizeMake(self.frame.size.width, self.frame.size.height + 1) // Add one to make it scrollable.
                self.goUp()
            }
        } else {
            /// Increase the size of the ScrollView orientation for the view to be scrollable.
            switch orientation {
            case .horizontal:
                self.documentSize = CGSizeMake(self.frame.size.width * self.contentMultiplier, self.frame.size.height)
            case .vertical:
                self.documentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * self.contentMultiplier)
            }
            self.recenterIfNecessary(beforeIndexUndefined: beforeIndex == nil, afterIndexUndefined: afterIndex == nil)
        }
        
        switch orientation {
        case .horizontal:
            let visibleBounds: CGRect = self.convert(self.contentView.bounds, to: self)
            let minimumVisibleX: CGFloat = CGRectGetMinX(visibleBounds)
            let maximumVisibleX: CGFloat = CGRectGetMaxX(visibleBounds)
            
            self.redrawViewsX(minimumVisibleX: minimumVisibleX, toMaxX: maximumVisibleX, beforeIndex: beforeIndex, afterIndex: afterIndex, isLittle: isLittle)
        case .vertical:
            let visibleBounds: CGRect = self.convert(self.contentView.bounds, to: self)
            let minimumVisibleY: CGFloat = CGRectGetMinY(visibleBounds)
            let maximumVisibleY: CGFloat = CGRectGetMaxY(visibleBounds)
            
            self.redrawViewsY(minimumVisibleY: minimumVisibleY, toMaxY: maximumVisibleY, beforeIndex: beforeIndex, afterIndex: afterIndex, isLittle: isLittle)
        }
        
        self.sameTimeLayout -= 1
    }
    
    /// Creates a new view and add it to the ScrollView, returns nil if there was an error during the view's creation.
    private func insertView() -> NSView {
        let view = content(changeIndex)
        view.frame = self.contentFrame(changeIndex)
        //view.wantsLayer = false
        //view.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.documentView?.addSubview(view)
        return view
    }
    
    /// Creates a new view and add it to the end of the ScrollView, returns nil if there is no more content to be displayed.
    private func createAndAppendNewViewToEnd() -> NSView? {
        if let lastchangeIndex = visibleLabels.last {
            guard let newChangeIndex = self.changeIndexIncreaseAction(lastchangeIndex.1) else { return nil }
            changeIndex = newChangeIndex
        }
        
        let newView = self.insertView()
        self.visibleLabels.append((newView, changeIndex))
        return newView
    }
    
    /// Creates and append a new view to the right, returns nil if there is no more content to be displayed.
    private func placeNewViewToRight(rightEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToEnd() else { return nil }
        
        var frame: CGRect = newView.frame
        frame.origin.x = rightEdge
        //        frame.origin.y = 0 // avoid having unaligned elements
        
        newView.frame = frame
        
        return CGRectGetMaxX(frame)
    }
    
    /// Creates and append a new view to the bottom, returns nil if there is no more content to be displayed.
    private func placeNewViewToBottom(bottomEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToEnd() else { return nil }
        
        var frame: CGRect = newView.frame
        //        frame.origin.x = 0 // avoid having unaligned elements
        frame.origin.y = bottomEdge
        
        newView.frame = frame
        
        return CGRectGetMaxY(frame)
    }
    
    /// Creates a new view and add it to the beginning of the ScrollView, returns nil if there is no more content to be displayed.
    private func createAndAppendNewViewToBeginning() -> NSView? {
        if let firstchangeIndex = visibleLabels.first {
            guard let newChangeIndex = self.changeIndexDecreaseAction(firstchangeIndex.1) else { return nil }
            changeIndex = newChangeIndex
        }
        
        let newView = self.insertView()
        self.visibleLabels.insert((newView, changeIndex), at: 0)
        return newView
    }
    
    /// Creates and append a new view to the left, returns nil if there is no more content to be displayed.
    private func placeNewViewToLeft(leftEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToBeginning() else { return nil }
        
        var frame: CGRect = newView.frame
        frame.origin.x = leftEdge - frame.size.width
        //        frame.origin.y = 0 // avoid having unaligned elements
        
        newView.frame = frame
        
        return CGRectGetMinX(frame)
    }
    
    /// Creates and append a new view to the top, returns nil if there is no more content to be displayed.
    private func placeNewViewToTop(topEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToBeginning() else { return nil }
        
        var frame: CGRect = newView.frame
        //        frame.origin.x = 0 // avoid having unaligned elements
        frame.origin.y = topEdge - frame.size.height
        
        newView.frame = frame
        
        return CGRectGetMinY(frame)
    }
    
    /// Add views to the blank screen and removes the ones who aren't displayed anymore.
    private func redrawViewsX(minimumVisibleX: CGFloat, toMaxX maximumVisibleX: CGFloat, beforeIndex: ChangeIndex?, afterIndex: ChangeIndex?, isLittle: Bool) {
        
        /// Checks whether there is any visible view in the ScrollView, if not then it will try to create one.
        if self.visibleLabels.isEmpty {
            if self.placeNewViewToLeft(leftEdge: minimumVisibleX) == nil {
                self.goLeft()
                return
            }
            /// Start with the first element and not the second (as the method shifts the second element to the first position).
            self.visibleLabels.first?.0.frame.origin.x += self.visibleLabels.first?.0.frame.width ?? 0 + spacing
        }
        
        /// If beforeIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if beforeIndex != nil, let firstLabel = self.visibleLabels.first?.0 {
            /// Add labels that are missing on left side.
            var leftEdge: CGFloat = CGRectGetMinX(firstLabel.frame)
            while (leftEdge > minimumVisibleX) {
                if let newLeftEdge = self.placeNewViewToLeft(leftEdge: leftEdge) {
                    leftEdge = newLeftEdge
                } else {
                    self.goLeft()
                    return
                }
            }
        }
        
        /// If afterIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if afterIndex != nil, let lastLabel = self.visibleLabels.last?.0 {
            /// Add labels that are missing on right side
            var rightEdge: CGFloat = CGRectGetMaxX(lastLabel.frame)
            while (rightEdge < maximumVisibleX) {
                if let newRightEdge = self.placeNewViewToRight(rightEdge: rightEdge) {
                    rightEdge = newRightEdge
                } else {
                    if !isLittle {
                        self.goRight()
                    }
                    return
                }
            }
        }
        
        /// Remove labels that have fallen off right edge (not visible anymore).
        if var lastLabel = self.visibleLabels.last?.0 {
            while (CGRectGetMinX(lastLabel.frame) > maximumVisibleX) {
                lastLabel.removeFromSuperview()
                self.visibleLabels.removeLast()
                guard let newFirstLabel = self.visibleLabels.last?.0 else { break }
                lastLabel = newFirstLabel
            }
        }
        
        /// Remove labels that have fallen off left edge (not visible anymore).
        if var firstLabel = self.visibleLabels.first?.0 {
            while (CGRectGetMaxX(firstLabel.frame) < minimumVisibleX) {
                firstLabel.removeFromSuperview()
                self.visibleLabels.removeFirst()
                guard let newFirstLabel = self.visibleLabels.first?.0 else { break }
                firstLabel = newFirstLabel
            }
        }
    }
    
    private func redrawViewsY(minimumVisibleY: CGFloat, toMaxY maximumVisibleY: CGFloat, beforeIndex: ChangeIndex?, afterIndex: ChangeIndex?, isLittle: Bool) {
        
        /// Checks whether there is any visible view in the ScrollView, if not then it will try to create one.
        if self.visibleLabels.isEmpty {
            if self.placeNewViewToTop(topEdge: minimumVisibleY) == nil {
                self.goUp()
                return
            }
            /// Start with the first element and not the second (as the method shifts the second element to the first position).
            self.visibleLabels.first?.0.frame.origin.y += self.visibleLabels.first?.0.frame.height ?? 0 + spacing
        }
        
        /// If beforeIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if beforeIndex != nil, let firstLabel = self.visibleLabels.first?.0 {
            /// Add labels that are missing on top side.
            var topEdge: CGFloat = CGRectGetMinY(firstLabel.frame)
            while (topEdge > minimumVisibleY) {
                if let newTopEdge = self.placeNewViewToTop(topEdge: topEdge) {
                    topEdge = newTopEdge
                } else {
                    self.goUp()
                    break
                }
            }
        }
        
        /// If afterIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if afterIndex != nil, let lastLabel = self.visibleLabels.last?.0 {
            /// Add labels that are missing on bottom side.
            var bottomEdge: CGFloat = CGRectGetMaxY(lastLabel.frame)
            while (bottomEdge < maximumVisibleY) {
                if let newBottomEdge = self.placeNewViewToBottom(bottomEdge: bottomEdge) {
                    bottomEdge = newBottomEdge
                } else {
                    if !isLittle {
                        self.goDown()
                    }
                    break
                }
            }
        }
        
        /// Remove labels that have fallen off bottom edge.
        if var lastLabel = self.visibleLabels.last?.0 {
            while (CGRectGetMinY(lastLabel.frame) > maximumVisibleY) {
                lastLabel.removeFromSuperview()
                self.visibleLabels.removeLast()
                guard let newLastLabel = self.visibleLabels.last?.0 else { break }
                lastLabel = newLastLabel
            }
        }
        
        /// Remove labels that have fallen off top edge.
        if var firstLabel = self.visibleLabels.first?.0 {
            while (CGRectGetMaxY(firstLabel.frame) < minimumVisibleY) {
                firstLabel.removeFromSuperview()
                self.visibleLabels.removeFirst()
                guard let newFirstLabel = self.visibleLabels.first?.0 else { break }
                firstLabel = newFirstLabel
            }
        }
    }
    
    /// Orientation possibilities of the NSInfiniteScrollView
    public enum Orientation {
        case horizontal
        case vertical
    }
}

// https://stackoverflow.com/a/14572970/16456439
extension NSInfiniteScrollView {
    var documentSize: NSSize {
        set { documentView?.setFrameSize(newValue) }
        get { documentView?.frame.size ?? NSSize.zero }
    }
    var documentOffset: NSPoint {
        set { if sameTimeLayout < 2 { self.documentView?.scroll(newValue) } }
        get { documentVisibleRect.origin }
    }
}

extension NSView {
    var center: NSPoint {
        get { NSPoint(x: self.frame.midX, y: self.frame.midY) }
        set { frame.origin = NSPoint(x: newValue.x - (frame.size.width / 2), y: newValue.y - (frame.size.height / 2)) }
    }
}

#else

/// UIKit component of the InfiniteScrollView.
///
/// Generic types:
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
public class UIInfiniteScrollView<ChangeIndex>: UIScrollView, UIScrollViewDelegate {
    
    /// Number that will be used to multiply to the view frame height/width so it can scroll.
    ///
    /// Can be used to reduce high-speed scroll lag, set it higher if you need to increment the maximum scroll speed.
    private var contentMultiplier: CGFloat
    
    /// Data that will be passed to draw the view and get its frame.
    private var changeIndex: ChangeIndex
    
    /// Function called to get the content to display for a particular ChangeIndex.
    private let content: (ChangeIndex) -> UIView
    
    /// The frame of the content to be displayed.
    private let contentFrame: (ChangeIndex) -> CGRect
    
    /// Function that get the ChangeIndex after another.
    ///
    /// Should return nil if there is no more content to display (end of the ScrollView at the bottom/right).
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
    private let changeIndexIncreaseAction: (ChangeIndex) -> ChangeIndex?
    
    /// Function that get the ChangeIndex before another.
    ///
    /// Should return nil if there is no more content to display (end of the ScrollView at the top/left).
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
    private let changeIndexDecreaseAction: (ChangeIndex) -> ChangeIndex?
    
    /// Orientation of the ScrollView.
    private let orientation: Orientation
    
    /// Action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything.
    ///
    /// Gives an action that must be used in order for refresh to end.
    public let refreshAction: ((@escaping () -> Void) -> ())?
    
    /// Space between the views.
    private let spacing: CGFloat
    
    /// Array containing the displayed views and their associated data.
    private var visibleLabels: [(UIView, ChangeIndex)]
    
    /// Creates an instance of UIInfiniteScrollView.
    /// - Parameters:
    ///   - frame: Frame of the view.
    ///   - content: Function called to get the content to display for a particular ChangeIndex.
    ///   - contentFrame: The frame of the content to be displayed.
    ///   - changeIndex: Data that will be passed to draw the view and get its frame, for the first view that will be displayed at init.
    ///   - changeIndexIncreaseAction: Function that get the ChangeIndex after another. Should return nil if there is no more content to display (end of the ScrollView at the bottom/right).
    ///   - changeIndexDecreaseAction: Function that get the ChangeIndex before another. Should return nil if there is no more content to display (end of the ScrollView at the top/left).
    ///   - contentMultiplier: Number that will be used to multiply to the view frame height/width so it can scroll. Can be used to reduce high-speed scroll lag, set it higher if you need to increment the maximum scroll speed.
    ///   - orientation: Orientation of the ScrollView.
    ///   - refreshAction: Action to do when the user pull the InfiniteScrollView to the top to refresh the content, should be nil if there is no need to refresh anything. Gives an action that must be used in order for refresh to end.
    ///   - spacing: Space between the views.
    public init(
        frame: CGRect,
        content: @escaping (ChangeIndex) -> UIView,
        contentFrame: @escaping (ChangeIndex) -> CGRect,
        changeIndex: ChangeIndex,
        changeIndexIncreaseAction: @escaping (ChangeIndex) -> ChangeIndex?,
        changeIndexDecreaseAction: @escaping (ChangeIndex) -> ChangeIndex?,
        contentMultiplier: CGFloat = 6,
        orientation: Orientation,
        refreshAction: ((@escaping () -> Void) -> ())?,
        spacing: CGFloat = 0
    ) {
        self.visibleLabels = []
        self.content = content
        self.contentFrame = contentFrame
        self.changeIndex = changeIndex
        self.changeIndexIncreaseAction = changeIndexIncreaseAction
        self.changeIndexDecreaseAction = changeIndexDecreaseAction
        self.contentMultiplier = contentMultiplier
        self.orientation = orientation
        self.refreshAction = refreshAction
        self.spacing = spacing
        super.init(frame: frame)
        /// Increase the size of the ScrollView orientation for the view to be scrollable.
        switch orientation {
        case .horizontal:
            self.contentSize = CGSizeMake(self.frame.size.width * self.contentMultiplier, self.frame.size.height)
        case .vertical:
            self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * self.contentMultiplier)
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        if self.refreshAction != nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(refreshActionMethod), for: .valueChanged)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, please open a PR if you would like it to be implemented")
    }
    
    /// Execute the scroll action if it is defined.
    @objc private func refreshActionMethod() {
        if let refreshAction = self.refreshAction, let endAction = self.refreshControl?.endRefreshing {
            refreshAction(endAction)
        } else {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    /// Recenter content periodically to achieve impression of infinite scrolling
    private func recenterIfNecessary(beforeIndexUndefined: Bool, afterIndexUndefined: Bool) {
        switch orientation {
        case .horizontal:
            let currentOffset: CGPoint = self.contentOffset
            let contentWidth: CGFloat = self.contentSize.width
            let centerOffsetX: CGFloat = (contentWidth - self.bounds.size.width) / 2
            let distanceFromCenter: CGFloat = abs(currentOffset.x - centerOffsetX)
            
            if beforeIndexUndefined {
                self.goLeft()
            } else if afterIndexUndefined {
                self.goRight()
            } else {
                if distanceFromCenter > (contentWidth / contentMultiplier) {
                    self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y)
                    
                    /// Move content by the same amount so it appears to stay still.
                    for (label, _) in self.visibleLabels {
                        var center: CGPoint = self.convert(label.center, to: self)
                        center.x += (centerOffsetX - currentOffset.x)
                        label.center = self.convert(center, to: self)
                    }
                }
            }
        case .vertical:
            let currentOffset: CGPoint = self.contentOffset
            let contentHeight: CGFloat = self.contentSize.height
            let centerOffsetY: CGFloat = (contentHeight - self.bounds.size.height) / 2
            let distanceFromCenter: CGFloat = abs(currentOffset.y - centerOffsetY)
            
            if beforeIndexUndefined {
                self.goUp()
            } else if afterIndexUndefined {
                self.goDown()
            } else {
                if distanceFromCenter > (contentHeight / contentMultiplier) {
                    self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY)
                    
                    /// Move content by the same amount so it appears to stay still.
                    for (label, _) in self.visibleLabels {
                        var center: CGPoint = self.convert(label.center, to: self)
                        center.y += (centerOffsetY - currentOffset.y)
                        label.center = self.convert(center, to: self)
                    }
                }
            }
        }
    }
    
    /// Recenter all the views to the top.
    private func goUp() {
        /// Move content by the same amount so it appears to stay still.
        var pointsFromTop: CGFloat = 0
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels {
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            if !changedMainOffset {
                self.contentOffset.y -= origin.y
                changedMainOffset = true
            }
            origin.y = pointsFromTop
            label.frame.origin = self.convert(origin, to: self)
            pointsFromTop += label.frame.height + spacing
        }
    }
    
    /// Recenter all the views to the left.
    private func goLeft() {
        /// Move content by the same amount so it appears to stay still.
        var pointsFromLeft: CGFloat = 0
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels {
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            origin.x = pointsFromLeft
            if !changedMainOffset {
                self.contentOffset.x -= origin.x
                changedMainOffset = true
            }
            label.frame.origin = self.convert(origin, to: self)
            pointsFromLeft += label.frame.width + spacing
        }
    }
    
    /// Recenter all the views to the bottom.
    private func goDown() {
        /// Move content by the same amount so it appears to stay still.
        var pointsToTop: CGFloat = self.contentSize.height
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels.reversed() {
            pointsToTop -= label.frame.height
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            if !changedMainOffset {
                self.contentOffset.y += pointsToTop - origin.y
                changedMainOffset = true
            }
            origin.y = pointsToTop
            label.frame.origin = self.convert(origin, to: self)
            pointsToTop -= spacing
        }
    }
    
    /// Recenter all the views to the right.
    private func goRight() {
        /// Move content by the same amount so it appears to stay still.
        var pointsToLeft: CGFloat = self.contentSize.width
        var changedMainOffset: Bool = false
        for (label, _) in self.visibleLabels.reversed() {
            pointsToLeft -= label.frame.width
            var origin: CGPoint = self.convert(label.frame.origin, to: self)
            if !changedMainOffset {
                self.contentOffset.x += pointsToLeft - origin.x
                changedMainOffset = true
            }
            origin.x = pointsToLeft
            label.frame.origin = self.convert(origin, to: self)
            pointsToLeft -= spacing
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        /// Get the before and after indexes.
        let beforeIndex = {
            if let firstchangeIndex = self.visibleLabels.first {
                return self.changeIndexDecreaseAction(firstchangeIndex.1)
            } else {
                /// No view in visibleLabels, need to create one with the current changeIndex
                return self.changeIndexDecreaseAction(self.changeIndex)
            }
        }()
        let afterIndex = {
            if let lastchangeIndex = self.visibleLabels.last {
                return self.changeIndexIncreaseAction(lastchangeIndex.1)
            } else {
                /// No view in visibleLabels, need to create one with the current changeIndex
                return self.changeIndexIncreaseAction(self.changeIndex)
            }
        }()
        /// Checks whether the content to display takes less than the height of the screen (in that case it will reduce the size of the frame to avoid all the recentering/resizing operations).
        let isLittle =
        (orientation == .horizontal && (self.visibleLabels.last?.0.frame.origin.x ?? 0) + (self.visibleLabels.last?.0.frame.width ?? 0) - (self.visibleLabels.first?.0.frame.origin.x ?? 0) < self.frame.size.width + 1)
        ||
        (orientation == .vertical && (self.visibleLabels.last?.0.frame.origin.y ?? 0) + (self.visibleLabels.last?.0.frame.height ?? 0) - (self.visibleLabels.first?.0.frame.origin.y ?? 0) < self.frame.size.height + 1)

        if beforeIndex == nil && afterIndex == nil, isLittle {
            switch orientation {
            case .horizontal:
                self.contentSize = CGSizeMake(self.frame.size.width + 1, self.frame.size.height) // Add one to make it scrollable.
                self.goLeft()
            case .vertical:
                self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height + 1) // Add one to make it scrollable.
                self.goUp()
            }
        } else {
            /// Increase the size of the ScrollView orientation for the view to be scrollable.
            switch orientation {
            case .horizontal:
                self.contentSize = CGSizeMake(self.frame.size.width * self.contentMultiplier, self.frame.size.height)
            case .vertical:
                self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * self.contentMultiplier)
            }
            self.recenterIfNecessary(beforeIndexUndefined: beforeIndex == nil, afterIndexUndefined: afterIndex == nil)
        }
        
        switch orientation {
        case .horizontal:
            let visibleBounds: CGRect = self.convert(self.bounds, to: self)
            let minimumVisibleX: CGFloat = CGRectGetMinX(visibleBounds)
            let maximumVisibleX: CGFloat = CGRectGetMaxX(visibleBounds)
            
            self.redrawViewsX(minimumVisibleX: minimumVisibleX, toMaxX: maximumVisibleX, beforeIndex: beforeIndex, afterIndex: afterIndex, isLittle: isLittle)
        case .vertical:
            let visibleBounds: CGRect = self.convert(self.bounds, to: self)
            let minimumVisibleY: CGFloat = CGRectGetMinY(visibleBounds)
            let maximumVisibleY: CGFloat = CGRectGetMaxY(visibleBounds)
            
            self.redrawViewsY(minimumVisibleY: minimumVisibleY, toMaxY: maximumVisibleY, beforeIndex: beforeIndex, afterIndex: afterIndex, isLittle: isLittle)
        }
    }
    
    /// Creates a new view and add it to the ScrollView, returns nil if there was an error during the view's creation.
    private func insertView() -> UIView {
        let view = content(changeIndex)
        view.frame = self.contentFrame(changeIndex)
        view.backgroundColor = .clear
        self.addSubview(view)
        return view
    }
    
    /// Creates a new view and add it to the end of the ScrollView, returns nil if there is no more content to be displayed.
    private func createAndAppendNewViewToEnd() -> UIView? {
        if let lastchangeIndex = visibleLabels.last {
            guard let newChangeIndex = self.changeIndexIncreaseAction(lastchangeIndex.1) else { return nil }
            changeIndex = newChangeIndex
        }
        
        let newView = self.insertView()
        self.visibleLabels.append((newView, changeIndex))
        return newView
    }
    
    /// Creates and append a new view to the right, returns nil if there is no more content to be displayed.
    private func placeNewViewToRight(rightEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToEnd() else { return nil }
        
        var frame: CGRect = newView.frame
        frame.origin.x = rightEdge
        //        frame.origin.y = 0 // avoid having unaligned elements
        
        newView.frame = frame
        
        return CGRectGetMaxX(frame)
    }
    
    /// Creates and append a new view to the bottom, returns nil if there is no more content to be displayed.
    private func placeNewViewToBottom(bottomEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToEnd() else { return nil }
        
        var frame: CGRect = newView.frame
        //        frame.origin.x = 0 // avoid having unaligned elements
        frame.origin.y = bottomEdge
        
        newView.frame = frame
        
        return CGRectGetMaxY(frame)
    }
    
    /// Creates a new view and add it to the beginning of the ScrollView, returns nil if there is no more content to be displayed.
    private func createAndAppendNewViewToBeginning() -> UIView? {
        if let firstchangeIndex = visibleLabels.first {
            guard let newChangeIndex = self.changeIndexDecreaseAction(firstchangeIndex.1) else { return nil }
            changeIndex = newChangeIndex
        }
        
        let newView = self.insertView()
        self.visibleLabels.insert((newView, changeIndex), at: 0)
        return newView
    }
    
    /// Creates and append a new view to the left, returns nil if there is no more content to be displayed.
    private func placeNewViewToLeft(leftEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToBeginning() else { return nil }
        
        var frame: CGRect = newView.frame
        frame.origin.x = leftEdge - frame.size.width
        //        frame.origin.y = 0 // avoid having unaligned elements
        
        newView.frame = frame
        
        return CGRectGetMinX(frame)
    }
    
    /// Creates and append a new view to the top, returns nil if there is no more content to be displayed.
    private func placeNewViewToTop(topEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToBeginning() else { return nil }
        
        var frame: CGRect = newView.frame
        //        frame.origin.x = 0 // avoid having unaligned elements
        frame.origin.y = topEdge - frame.size.height
        
        newView.frame = frame
        
        return CGRectGetMinY(frame)
    }
    
    /// Add views to the blank screen and removes the ones who aren't displayed anymore.
    private func redrawViewsX(minimumVisibleX: CGFloat, toMaxX maximumVisibleX: CGFloat, beforeIndex: ChangeIndex?, afterIndex: ChangeIndex?, isLittle: Bool) {
        
        /// Checks whether there is any visible view in the ScrollView, if not then it will try to create one.
        if self.visibleLabels.isEmpty {
            if self.placeNewViewToLeft(leftEdge: minimumVisibleX) == nil {
                self.goLeft()
                return
            }
            /// Start with the first element and not the second (as the method shifts the second element to the first position).
            self.visibleLabels.first?.0.frame.origin.x += self.visibleLabels.first?.0.frame.width ?? 0 + spacing
        }
        
        /// If beforeIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if beforeIndex != nil, let firstLabel = self.visibleLabels.first?.0 {
            /// Add labels that are missing on left side.
            var leftEdge: CGFloat = CGRectGetMinX(firstLabel.frame)
            while (leftEdge > minimumVisibleX) {
                if let newLeftEdge = self.placeNewViewToLeft(leftEdge: leftEdge) {
                    leftEdge = newLeftEdge
                } else {
                    self.goLeft()
                    return
                }
            }
        }
        
        /// If afterIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if afterIndex != nil, let lastLabel = self.visibleLabels.last?.0 {
            /// Add labels that are missing on right side
            var rightEdge: CGFloat = CGRectGetMaxX(lastLabel.frame)
            while (rightEdge < maximumVisibleX) {
                if let newRightEdge = self.placeNewViewToRight(rightEdge: rightEdge) {
                    rightEdge = newRightEdge
                } else {
                    if !isLittle {
                        self.goRight()
                    }
                    return
                }
            }
        }
        
        /// Remove labels that have fallen off right edge (not visible anymore).
        if var lastLabel = self.visibleLabels.last?.0 {
            while (CGRectGetMinX(lastLabel.frame) > maximumVisibleX) {
                lastLabel.removeFromSuperview()
                self.visibleLabels.removeLast()
                guard let newFirstLabel = self.visibleLabels.last?.0 else { break }
                lastLabel = newFirstLabel
            }
        }
        
        /// Remove labels that have fallen off left edge (not visible anymore).
        if var firstLabel = self.visibleLabels.first?.0 {
            while (CGRectGetMaxX(firstLabel.frame) < minimumVisibleX) {
                firstLabel.removeFromSuperview()
                self.visibleLabels.removeFirst()
                guard let newFirstLabel = self.visibleLabels.first?.0 else { break }
                firstLabel = newFirstLabel
            }
        }
    }
    
    private func redrawViewsY(minimumVisibleY: CGFloat, toMaxY maximumVisibleY: CGFloat, beforeIndex: ChangeIndex?, afterIndex: ChangeIndex?, isLittle: Bool) {
        
        /// Checks whether there is any visible view in the ScrollView, if not then it will try to create one.
        if self.visibleLabels.isEmpty {
            if self.placeNewViewToTop(topEdge: minimumVisibleY) == nil {
                self.goUp()
                return
            }
            /// Start with the first element and not the second (as the method shifts the second element to the first position).
            self.visibleLabels.first?.0.frame.origin.y += self.visibleLabels.first?.0.frame.height ?? 0 + spacing
        }
        
        /// If beforeIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if beforeIndex != nil, let firstLabel = self.visibleLabels.first?.0 {
            /// Add labels that are missing on top side.
            var topEdge: CGFloat = CGRectGetMinY(firstLabel.frame)
            while (topEdge > minimumVisibleY) {
                if let newTopEdge = self.placeNewViewToTop(topEdge: topEdge) {
                    topEdge = newTopEdge
                } else {
                    self.goUp()
                    break
                }
            }
        }
        
        /// If afterIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if afterIndex != nil, let lastLabel = self.visibleLabels.last?.0 {
            /// Add labels that are missing on bottom side.
            var bottomEdge: CGFloat = CGRectGetMaxY(lastLabel.frame)
            while (bottomEdge < maximumVisibleY) {
                if let newBottomEdge = self.placeNewViewToBottom(bottomEdge: bottomEdge) {
                    bottomEdge = newBottomEdge
                } else {
                    if !isLittle {
                        self.goDown()
                    }
                    break
                }
            }
        }
        
        /// Remove labels that have fallen off bottom edge.
        if var lastLabel = self.visibleLabels.last?.0 {
            while (CGRectGetMinY(lastLabel.frame) > maximumVisibleY) {
                lastLabel.removeFromSuperview()
                self.visibleLabels.removeLast()
                guard let newLastLabel = self.visibleLabels.last?.0 else { break }
                lastLabel = newLastLabel
            }
        }
        
        /// Remove labels that have fallen off top edge.
        if var firstLabel = self.visibleLabels.first?.0 {
            while (CGRectGetMaxY(firstLabel.frame) < minimumVisibleY) {
                firstLabel.removeFromSuperview()
                self.visibleLabels.removeFirst()
                guard let newFirstLabel = self.visibleLabels.first?.0 else { break }
                firstLabel = newFirstLabel
            }
        }
    }
    
    /// Orientation possibilities of the UIInfiniteScrollView
    public enum Orientation {
        case horizontal
        case vertical
    }
}

#endif
