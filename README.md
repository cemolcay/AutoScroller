AutoScroller
====
Display custom "scroll to top" or "scroll to bottom" views in to all UIScrollView instances while they are scrolling

Install
---
### CocoaPods
``` ruby
use_frameworks!
pod 'AutoScroller'
```

Requierments
---
* Swift 3
* Xcode 8
* iOS 10+
* tvOS 10+

Usage
---
`AutoScrollable` is a protocol that enables the functions of adding scrollToTop and scrollToBottom views.
UIScrollView extesion implements `AutoScrollable` in `AutoScrollable.swift` with `AutoScrollerView` and `AutoTimer` helper classes.
  
In your view controller call
* `addScrollToTopScroller(with scroller: AutoScrollerView)` to add  `scrollToTopScroller` when user starts to scroll upwards.
* `addScrollToBottomScroller(with scroller: AutoScrollerView)` to add `scrollToBottomScroller` when user starts to scroll downwards.
* Or else, what do you want, where do you want with `AutoScrollerViewPosition` with custom offset support.

Basic usage would likely:
``` swift
class ViewController: UIViewController, UIScrollViewDelegate {
  @IBOutlet weak var scrollView: UIScrollView!

  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    scrollView.contentSize.height = 2000

    // Add scroll to top scroller
    let scrollToTopView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    scrollToTopView.backgroundColor = .lightGray

    scrollView.addScrollToTopScroller(with: AutoScrollerView(
      contentView: scrollToTopView,
      position:
        .bottomRight(bottomOffset: 10, rightOffset: 10)
    ))

    // Add scroll to bottom scroller
    let scrollToBottomView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    scrollToBottomView.backgroundColor = .darkGray

    scrollView.addScrollToBottomScroller(with: AutoScrollerView(
      contentView: scrollToBottomView,
      position:
      .topRight(topOffset: 10, rightOffset: 10)
    ))
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.updateAutoScroller()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollView.hideAutoScroller()
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    scrollView.hideAutoScroller()
  }

  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    scrollView.hideAutoScroller()
  }
}
```
