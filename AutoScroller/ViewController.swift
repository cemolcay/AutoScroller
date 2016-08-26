//
//  ViewController.swift
//  AutoScrollerView
//
//  Created by Cem Olcay on 25/08/16.
//  Copyright © 2016 Prototapp. All rights reserved.
//

import UIKit

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

