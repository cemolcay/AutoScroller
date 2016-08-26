//
//  AutoScrollingView.swift
//  AutoScrollerView
//
//  Created by Cem Olcay on 25/08/16.
//  Copyright © 2016 Prototapp. All rights reserved.
//

import UIKit

@objc open class AutoTimer: NSObject {
  static let shared = AutoTimer()
  private var timer: Timer?
  private var timerAction: (() -> Void)?

  open func start(for duration: TimeInterval, repeats: Bool = false, after: (() -> Void)? = nil) {
    stop()
    timerAction = after
    timer = Timer.scheduledTimer(
      timeInterval: duration,
      target: self,
      selector: #selector(AutoTimer.timerDidStop),
      userInfo: nil,
      repeats: repeats)
    RunLoop.main.add(timer!, forMode: .commonModes)
  }

  open func stop() {
    timer?.invalidate()
    timer = nil
  }

  public func timerDidStop() {
    stop()
    DispatchQueue.main.async { [weak self] in
      self?.timerAction?()
    }
  }
}

public enum AutoScrollerViewPosition {
  case topLeft(topOffset: CGFloat, leftOffset: CGFloat)
  case topRight(topOffset: CGFloat, rightOffset: CGFloat)
  case bottomLeft(bottomOffset: CGFloat, leftOffset: CGFloat)
  case bottomRight(bottomOffset: CGFloat, rightOffset: CGFloat)
}

open class AutoScrollerView: UIControl {
  internal var didPress: (() -> Void)?

  private var contentViewConstraints = [NSLayoutConstraint]()
  private var positionConstraints = [NSLayoutConstraint]()
  private var sizeConstraints = [NSLayoutConstraint]()

  public var position: AutoScrollerViewPosition {
    didSet {
      setupPosition()
    }
  }

  public var contentView: UIView {
    didSet {
      setupContentView()
    }
  }

  // MARK: Init
  public override init(frame: CGRect) {
    position = .bottomRight(bottomOffset: 10, rightOffset: 10)
    contentView = UIView(frame: CGRect.zero)
    super.init(frame: frame)
    commonInit()
  }

  required public init?(coder aDecoder: NSCoder) {
    position = .bottomRight(bottomOffset: 10, rightOffset: 10)
    contentView = UIView(frame: CGRect.zero)
    super.init(coder: aDecoder)
    commonInit()
  }

  public init(contentView: UIView, position: AutoScrollerViewPosition) {
    self.contentView = contentView
    self.position = position
    super.init(frame: contentView.frame)
    commonInit()
  }

  private func commonInit() {
    setupContentView()
    setupPosition()

    // setup action
    addTarget(
      self,
      action: #selector(AutoScrollerView.scrollerDidPress),
      for: .touchUpInside)
  }

  // MARK: Lifecycle
  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    setupPosition()
  }

  // MARK: Setup
  private func setupContentView() {
    // Remove all content view constraints
    removeConstraints(contentViewConstraints)

    // Remove all subviews for clean start
    contentViewConstraints = []
    for subview in subviews {
      subview.removeFromSuperview()
    }

    // Setup size
    setupSize()

    // Add content as subview
    addSubview(contentView)
    contentView.isUserInteractionEnabled = false
    contentView.translatesAutoresizingMaskIntoConstraints = false

    // Pin contentView edges to self
    contentViewConstraints = [
      contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
      contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
      contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    ]

    addConstraints(contentViewConstraints)
    contentViewConstraints.forEach({ $0.isActive = true })
  }

  private func setupSize() {
    // Remove all size constraints
    removeConstraints(sizeConstraints)

    // Add width and height constarints
    sizeConstraints = [
      NSLayoutConstraint(
        item: self,
        attribute: .width,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: contentView.frame.size.width),
      NSLayoutConstraint(
        item: self,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: contentView.frame.size.height)
    ]

    addConstraints(sizeConstraints)
  }

  private func setupPosition() {
    guard let superview = self.superview else { return }
    superview.removeConstraints(positionConstraints)
    translatesAutoresizingMaskIntoConstraints = false

    // Add edge constraints
    switch position {
    case .topLeft(let topOffset, let leftOffset):
      positionConstraints = [
        topAnchor.constraint(equalTo: superview.topAnchor, constant: topOffset),
        leftAnchor.constraint(equalTo: superview.leftAnchor, constant: leftOffset)
      ]
    case .topRight(let topOffset, let rightOffset):
      positionConstraints = [
         topAnchor.constraint(equalTo: superview.topAnchor, constant: topOffset),
         rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -rightOffset)
      ]
    case .bottomLeft(let bottomOffset, let leftOffset):
      positionConstraints = [
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottomOffset),
        leftAnchor.constraint(equalTo: superview.leftAnchor, constant: leftOffset)
      ]
    case .bottomRight(let bottomOffset, let rightOffset):
      positionConstraints = [
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottomOffset),
        rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -rightOffset)
      ]
    }

    positionConstraints.forEach({ $0.isActive = true })
  }

  // MARK: Action
  internal func scrollerDidPress() {
    didPress?()
  }
}

@objc public protocol AutoScrollable {
  var autoScrollingViewAppearAfterScrollingInterval: TimeInterval { get }
  func addScrollToTopScroller(with scroller: AutoScrollerView)
  func addScrollToBottomScroller(with scroller: AutoScrollerView)
  func removeScrollToTopScroller()
  func removeScrollToBottomScroller()
  func updateAutoScroller()
  func hideAutoScroller()
}

public enum ScrollingDirection {
  case no
  case up
  case down
}

public var AutoScrollableScrollingDirectionAssociatedObjectHandle: UInt8 = 0
public var AutoScrollableScrollToTopViewAssociatedObjectHandle: UInt8 = 1
public var AutoScrollableScrollToBottomViewAssociatedObjectHandle: UInt8 = 2
public var AutoScrollabelScrollViewPreviousContentOffsetAssociatedObjectHandle: UInt8 = 3

extension UIScrollView: AutoScrollable {

  private var autoScrollableScrollToTopView: UIControl? {
    get {
      return objc_getAssociatedObject(self, &AutoScrollableScrollToTopViewAssociatedObjectHandle) as? UIControl
    } set {
      objc_setAssociatedObject(self, &AutoScrollableScrollToTopViewAssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var autoScrollableScrollToBottomView: UIControl? {
    get {
      return objc_getAssociatedObject(self, &AutoScrollableScrollToBottomViewAssociatedObjectHandle) as? UIControl
    } set {
      objc_setAssociatedObject(self, &AutoScrollableScrollToBottomViewAssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var autoScrollabelScrollViewPreviousContentOffset: CGPoint? {
    get {
      return objc_getAssociatedObject(self, &AutoScrollabelScrollViewPreviousContentOffsetAssociatedObjectHandle) as? CGPoint ?? CGPoint.zero
    } set {
      objc_setAssociatedObject(self, &AutoScrollabelScrollViewPreviousContentOffsetAssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }

  // MARK: ScrollDirection
  private var scrollingDirection: ScrollingDirection {
    get {
      return objc_getAssociatedObject(self, &AutoScrollableScrollingDirectionAssociatedObjectHandle) as? ScrollingDirection ?? .no
    } set {
      let didSet = scrollingDirection != newValue
      objc_setAssociatedObject(self, &AutoScrollableScrollingDirectionAssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

      if didSet  {
        scrollingDirectionDidChange()
      }
    }
  }

  private func scrollingDirectionDidChange() {
    switch scrollingDirection {
    case .no:
      AutoTimer.shared.start(
        for: autoScrollingViewAppearAfterScrollingInterval,
        after: { [weak self] in
          guard let this = self, this.scrollingDirection == .no else { return }
          this.setHidden(scrollToTopScroller: true, scrollToBottomScroller: true)
        })
    case .up:
      setHidden(scrollToTopScroller: true, scrollToBottomScroller: true)
      AutoTimer.shared.start(
        for: autoScrollingViewAppearAfterScrollingInterval,
        after: { [weak self] in
          guard let this = self, this.scrollingDirection == .up else { return }
          this.setHidden(scrollToTopScroller: false, scrollToBottomScroller: true)
        })
    case .down:
      setHidden(scrollToTopScroller: true, scrollToBottomScroller: true)
      AutoTimer.shared.start(
        for: autoScrollingViewAppearAfterScrollingInterval,
        after: { [weak self] in
          guard let this = self, this.scrollingDirection == .down else { return }
          this.setHidden(scrollToTopScroller: true, scrollToBottomScroller: false)
        })
    }
  }

  // MARK: AutoScrollingView
  internal func scrollToTopButtonPressed(sender: UIButton) {
    if sender == autoScrollableScrollToTopView {
    }
  }

  internal func scrollToBottomButtonPressed(sender: UIButton) {
    if sender == autoScrollableScrollToBottomView {
    }
  }

  private func setHidden(scrollToTopScroller: Bool, scrollToBottomScroller: Bool) {
    autoScrollableScrollToTopView?.isHidden = scrollToTopScroller
    autoScrollableScrollToBottomView?.isHidden = scrollToBottomScroller
  }

  // MARK: AutoScrollable
  open var autoScrollingViewAppearAfterScrollingInterval: TimeInterval {
    return 0.5
  }

  open func addScrollToTopScroller(with scroller: AutoScrollerView) {
    guard let superview = self.superview else { fatalError("scrollView must have a superview") }
    guard autoScrollableScrollToTopView == nil else { return }

    scroller.isHidden = true
    scroller.didPress = { [weak self] in
      self?.autoScrollToTop()
      self?.setHidden(
        scrollToTopScroller: true,
        scrollToBottomScroller: true)
    }

    superview.addSubview(scroller)
    autoScrollableScrollToTopView = scroller
  }

  open func addScrollToBottomScroller(with scroller: AutoScrollerView) {
    guard let superview = self.superview else { fatalError("scrollView must have a superview") }
    guard autoScrollableScrollToBottomView == nil else { return }

    scroller.isHidden = true
    scroller.didPress = { [weak self] in
      self?.autoScrollToBottom()
      self?.setHidden(
        scrollToTopScroller: true,
        scrollToBottomScroller: true)
    }

    superview.addSubview(scroller)
    autoScrollableScrollToBottomView = scroller
  }

  open func removeScrollToTopScroller() {
    autoScrollableScrollToTopView?.removeFromSuperview()
    autoScrollableScrollToTopView = nil
  }

  open func removeScrollToBottomScroller() {
    autoScrollableScrollToBottomView?.removeFromSuperview()
    autoScrollableScrollToBottomView = nil
  }

  open func updateAutoScroller() {
    if autoScrollabelScrollViewPreviousContentOffset == nil {
      autoScrollabelScrollViewPreviousContentOffset = CGPoint.zero
    }

    scrollingDirection = contentOffset.y > autoScrollabelScrollViewPreviousContentOffset!.y ? .down : .up
    autoScrollabelScrollViewPreviousContentOffset = contentOffset
  }

  open func hideAutoScroller() {
    scrollingDirection = .no
  }

  open func autoScrollToTop(animated: Bool = true) {
    setContentOffset(
      CGPoint(x: 0, y: contentInset.top),
      animated: animated)
  }

  open func autoScrollToBottom(animated: Bool = true) {
    setContentOffset(
      CGPoint(x: 0, y: contentSize.height - frame.size.height),
      animated: animated)
  }
}
