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
#endif
import UIKit


/// SwiftUI InfiniteScrollView component.
///
/// Generic types:
/// - Content: a View.
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct InfiniteScrollView<Content: View, ChangeIndex>: UIViewRepresentable {
    public typealias UIViewType = UIInfiniteScrollView
    
    /// Frame of the view
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
    public let orientation: UIInfiniteScrollView<ChangeIndex>.Orientation
    
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
            orientation: orientation
        )
    }
    
    public func updateUIView(_ uiView: UIInfiniteScrollView<ChangeIndex>, context: Context) {}
}

/// UIKit component of the InfiniteScrollView.
///
/// Generic types:
/// - ChangeIndex: A type of data that will be given to draw the views and that will be increased and drecreased. It could be for example an Int, a Date or whatever you want.
public class UIInfiniteScrollView<ChangeIndex>: UIScrollView, UIScrollViewDelegate {
    
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
    
    /// Orientation of the ScrollView
    private let orientation: Orientation
    
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
    ///   - orientation: Orientation of the ScrollView
    public init(
        frame: CGRect,
        content: @escaping (ChangeIndex) -> UIView,
        contentFrame: @escaping (ChangeIndex) -> CGRect,
        changeIndex: ChangeIndex,
        changeIndexIncreaseAction: @escaping (ChangeIndex) -> ChangeIndex?,
        changeIndexDecreaseAction: @escaping (ChangeIndex) -> ChangeIndex?,
        orientation: Orientation
    ) {
        self.visibleLabels = []
        self.content = content
        self.contentFrame = contentFrame
        self.changeIndex = changeIndex
        self.changeIndexIncreaseAction = changeIndexIncreaseAction
        self.changeIndexDecreaseAction = changeIndexDecreaseAction
        self.orientation = orientation
        super.init(frame: frame)
        /// Increase the size of the ScrollView orientation for the view to be scrollable.
        switch orientation {
        case .horizontal:
            self.contentSize = CGSizeMake(self.frame.size.width * 6, self.frame.size.height)
        case .vertical:
            self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 6)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, please open a PR if you would like it to be implemented")
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
                //self.goLeft()
            } else if afterIndexUndefined {
                //self.goRight()
            } else {
                if distanceFromCenter > (contentWidth / 4) {
                    self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y)
                    
                    /// Move content by the same amount so it appears to stay still
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
                //self.goUp()
            } else if afterIndexUndefined {
                //self.goDown()
            } else {
                if distanceFromCenter > (contentHeight / 4) {
                    self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY)
                    
                    /// Move content by the same amount so it appears to stay still
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
    ///
    /// Unavailable because not ready.
    @available(*, unavailable)
    private func goUp() {
        let currentOffset: CGPoint = self.contentOffset
        self.contentOffset = CGPointMake(currentOffset.x, 0)
        
        // move content by the same amount so it appears to stay still
        var pointsFromTop: CGFloat = 0
        for (label, _) in self.visibleLabels {
            var center: CGPoint = self.convert(label.center, to: self)
            center.y = pointsFromTop
            label.center = self.convert(center, to: self)
            pointsFromTop += label.frame.height
        }
    }
    
    /// Recenter all the views to the bottom.
    ///
    /// Unavailable because not ready.
    @available(*, unavailable)
    private func goDown() {
        let currentOffset: CGPoint = self.contentOffset
        let contentHeight: CGFloat = self.contentSize.height
        self.contentOffset = CGPointMake(currentOffset.x, contentHeight)
        
        // move content by the same amount so it appears to stay still
        var pointsFromBottom: CGFloat = 0
        for (label, _) in self.visibleLabels.reversed() {
            var center: CGPoint = self.convert(label.center, to: self)
            center.y += contentHeight - pointsFromBottom
            label.center = self.convert(center, to: self)
            pointsFromBottom += label.frame.height
        }
    }
    
    /// Recenter all the views to the left.
    ///
    /// Unavailable because not ready.
    @available(*, unavailable)
    private func goLeft() {
        let currentOffset: CGPoint = self.contentOffset
        self.contentOffset = CGPointMake(0, currentOffset.y)
        
        // move content by the same amount so it appears to stay still
        for (label, _) in self.visibleLabels {
            var center: CGPoint = self.convert(label.center, to: self)
            center.x = 0
            label.center = self.convert(center, to: self)
        }
    }
    
    /// Recenter all the views to the right.
    ///
    /// Unavailable because not ready.
    @available(*, unavailable)
    private func goRight() {
        let currentOffset: CGPoint = self.contentOffset
        let contentWidth: CGFloat = self.contentSize.width
        self.contentOffset = CGPointMake(contentWidth, currentOffset.y)
        
        // move content by the same amount so it appears to stay still
        for (label, _) in self.visibleLabels {
            var center: CGPoint = self.convert(label.center, to: self)
            center.x = contentWidth
            label.center = self.convert(center, to: self)
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        /// Get the before and after indexes.
        let beforeIndex =
        if let firstchangeIndex = visibleLabels.first {
            self.changeIndexDecreaseAction(firstchangeIndex.1)
        } else {
            /// No view in visibleLabels, need to create one with the current changeIndex
            self.changeIndexDecreaseAction(changeIndex)
        }
        let afterIndex =
        if let lastchangeIndex = visibleLabels.last {
            self.changeIndexIncreaseAction(lastchangeIndex.1)
        } else {
            /// No view in visibleLabels, need to create one with the current changeIndex
            self.changeIndexIncreaseAction(changeIndex)
        }
        self.recenterIfNecessary(beforeIndexUndefined: beforeIndex == nil, afterIndexUndefined: afterIndex == nil)
        
        switch orientation {
        case .horizontal:
            let visibleBounds: CGRect = self.convert(self.bounds, to: self)
            let minimumVisibleX: CGFloat = CGRectGetMinX(visibleBounds)
            let maximumVisibleX: CGFloat = CGRectGetMaxX(visibleBounds)
            
            self.redrawViewsX(minimumVisibleX: minimumVisibleX, toMaxX: maximumVisibleX, beforeIndex: beforeIndex, afterIndex: afterIndex)
        case .vertical:
            let visibleBounds: CGRect = self.convert(self.bounds, to: self)
            let minimumVisibleY: CGFloat = CGRectGetMinY(visibleBounds)
            let maximumVisibleY: CGFloat = CGRectGetMaxY(visibleBounds)
            
            self.redrawViewsY(minimumVisibleY: minimumVisibleY, toMaxY: maximumVisibleY, beforeIndex: beforeIndex, afterIndex: afterIndex)
        }
    }
    
    /// Creates a new view and add it to the ScrollView, returns nil if there was an error during the view's creation.
    private func insertView() -> UIView {
        let view = content(changeIndex)
        view.frame = self.contentFrame(changeIndex)
        self.addSubview(view)
        return view
    }
    
    /// Creates a new view and add it to the end of the ScrollView, returns nil if there is no more content to be displayed.
    private func createAndAppendNewViewToEnd() -> UIView? {
        if let lastchangeIndex = visibleLabels.last {
            guard let newChangeIndex = self.changeIndexIncreaseAction(lastchangeIndex.1) else { return nil }
            changeIndex = newChangeIndex
        } else {
            guard let newChangeIndex = self.changeIndexIncreaseAction(changeIndex) else { return nil }
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
        //frame.origin.y = 0 // avoid having unaligned elements
        
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
        } else {
            guard let newChangeIndex = self.changeIndexDecreaseAction(changeIndex) else { return nil }
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
        //frame.origin.y = 0 // avoid having unaligned elements
        
        newView.frame = frame
        
        return CGRectGetMinX(frame)
    }
    
    /// Creates and append a new view to the top, returns nil if there was an error during the creation of the view or if there is no more content to be displayed.
    private func placeNewViewToTop(topEdge: CGFloat) -> CGFloat? {
        guard let newView = createAndAppendNewViewToBeginning() else { return nil }
        
        var frame: CGRect = newView.frame
        //frame.origin.x = 0 // avoid having unaligned elements
        frame.origin.y = topEdge - frame.size.height
        
        newView.frame = frame
        
        return CGRectGetMinY(frame)
    }
    
    /// Add views to the blank screen and removes the ones who aren't displayed anymore.
    private func redrawViewsX(minimumVisibleX: CGFloat, toMaxX maximumVisibleX: CGFloat, beforeIndex: ChangeIndex?, afterIndex: ChangeIndex?) {
        /// If afterIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if afterIndex != nil {
            /// Checks whether there is any visible view in the ScrollView, if not then it will try to create one.
            if self.visibleLabels.isEmpty {
                if self.placeNewViewToRight(rightEdge: minimumVisibleX) == nil {
                    //self.goRight()
                    return
                }
            }
            
            /// Add labels that are missing on right side
            let lastLabel: UIView = self.visibleLabels.last!.0
            var rightEdge: CGFloat = CGRectGetMaxX(lastLabel.frame)
            while (rightEdge < maximumVisibleX) {
                if let newRightEdge = self.placeNewViewToRight(rightEdge: rightEdge) {
                    rightEdge = newRightEdge
                } else {
                    //self.goRight()
                    return
                }
            }
        }
        
        /// If beforeIndex is nil it means that there is no more content to be displayed, otherwise it will draw and append it.
        if beforeIndex != nil {
            /// Checks whether there is any visible view in the ScrollView, if not then it will try to create one.
            if self.visibleLabels.isEmpty {
                if self.placeNewViewToLeft(leftEdge: minimumVisibleX) == nil {
                    //self.goLeft()
                    return
                }
            }
            
            /// Add labels that are missing on left side
            let firstLabel: UIView = self.visibleLabels[0].0
            var leftEdge: CGFloat = CGRectGetMinX(firstLabel.frame)
            while (leftEdge > minimumVisibleX) {
                if let newLeftEdge = self.placeNewViewToLeft(leftEdge: leftEdge) {
                    leftEdge = newLeftEdge
                } else {
                    //self.goLeft()
                    return
                }
            }
        }
        
        /// Remove labels that have fallen off right edge (not visible anymore).
        if var lastLabel = self.visibleLabels.last?.0 {
            while (lastLabel.frame.origin.x > maximumVisibleX) {
                lastLabel.removeFromSuperview()
                self.visibleLabels.removeLast()
                if self.visibleLabels.isEmpty {
                    break
                }
                lastLabel = self.visibleLabels.last!.0
            }
        }
        
        /// Remove labels that have fallen off left edge (not visible anymore).
        if var firstLabel = self.visibleLabels.first?.0 {
            while (CGRectGetMaxX(firstLabel.frame) < minimumVisibleX) {
                firstLabel.removeFromSuperview()
                self.visibleLabels.removeFirst()
                if self.visibleLabels.isEmpty {
                    break
                }
                firstLabel = self.visibleLabels[0].0
            }
        }
    }
    
    private func redrawViewsY(minimumVisibleY: CGFloat, toMaxY maximumVisibleY: CGFloat, beforeIndex: ChangeIndex?, afterIndex: ChangeIndex?) {
        if afterIndex != nil {
            if self.visibleLabels.isEmpty {
                if self.placeNewViewToBottom(bottomEdge: minimumVisibleY) == nil {
                    //self.goDown()
                    return
                }
            }
            
            /// Add labels that are missing on bottom side.
            let lastLabel: UIView = self.visibleLabels.last!.0
            var bottomEdge: CGFloat = CGRectGetMaxY(lastLabel.frame)
            while (bottomEdge < maximumVisibleY) {
                if let newBottomEdge = self.placeNewViewToBottom(bottomEdge: bottomEdge) {
                    bottomEdge = newBottomEdge
                } else {
                    //self.goDown()
                    return
                }
            }
        }
        
        if beforeIndex != nil {
            if self.visibleLabels.isEmpty {
                if self.placeNewViewToBottom(bottomEdge: minimumVisibleY) == nil {
                    //self.goDown()
                    return
                }
            }
            
            /// Add labels that are missing on top side.
            let firstLabel: UIView = self.visibleLabels[0].0
            var topEdge: CGFloat = CGRectGetMinY(firstLabel.frame)
            while (topEdge > minimumVisibleY) {
                if let newTopEdge = self.placeNewViewToTop(topEdge: topEdge) {
                    topEdge = newTopEdge
                } else {
                    //self.goUp()
                    return
                }
            }
        }
        
        /// Remove labels that have fallen off bottom edge.
        if var lastLabel = self.visibleLabels.last?.0 {
            while (lastLabel.frame.origin.y > maximumVisibleY) {
                lastLabel.removeFromSuperview()
                self.visibleLabels.removeLast()
                if self.visibleLabels.isEmpty {
                    break
                }
                lastLabel = self.visibleLabels.last!.0
            }
        }
        
        /// Remove labels that have fallen off top edge.
        if var firstLabel = self.visibleLabels.first?.0 {
            while (CGRectGetMaxY(firstLabel.frame) < minimumVisibleY) {
                firstLabel.removeFromSuperview()
                self.visibleLabels.removeFirst()
                if self.visibleLabels.isEmpty {
                    break
                }
                firstLabel = self.visibleLabels.first!.0
            }
        }
    }
    
    /// Orientation possibilities of the UIInfiniteScrollView
    public enum Orientation {
        case horizontal
        case vertical
    }
}