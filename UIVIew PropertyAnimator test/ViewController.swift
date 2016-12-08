//
//  ViewController.swift
//  UIVIew PropertyAnimator test
//
//  Created by Duncan Champney on 12/7/16.
//  Copyright © 2016 Duncan Champney. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
  
  //MARK: - IBOutlets
  
  @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var animationSlider: UISlider!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var reverseButton: UIButton!
  @IBOutlet weak var animationDirectionLabel: UILabel!
  //MARK: - Properties
  
  var animatingBackwards: Bool = false {
    didSet {
      viewAnimator.isReversed = animatingBackwards
      reverseButton.isEnabled = !animatingBackwards
      if animatingBackwards {
        animationDirectionLabel.text = NSLocalizedString("Backward", comment: "")
      } else {
        animationDirectionLabel.text = NSLocalizedString("Forward", comment: "")
      }
    }
  }
  
  var viewAnimator: UIViewPropertyAnimator!

  var animationIsRunning = false {
    didSet {
      if animationIsRunning {
        startStopButton.setTitle(NSLocalizedString("Pause", comment: ""), for: .normal)
        startTimer(true)
      } else {
        startStopButton.setTitle(NSLocalizedString("Start", comment: ""), for: .normal)
        startTimer(false)
      }
    }
  }
  
  let animationDuration = 2.0
  weak var timer: Timer?
  
  //MARK: - Overridden instance methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewAnimator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut)
    viewAnimator.isInterruptible = true
    }
  
  //MARK: - Custom Instance Methods
  
  func startTimer(_ start: Bool) {
    if start {
      timer = Timer.scheduledTimer(withTimeInterval: 0.02,
                                   repeats: true) {
                                    timer in
                                    var value = Float(self.viewAnimator.fractionComplete)
                                    if self.animatingBackwards {
                                      value = 1 - value
                                    }
                                    self.animationSlider.value = value
      }
    }
    else {
      self.timer?.invalidate()
    }
  }
  
  //MARK: - IBActions

  @IBAction func handleSlider(_ sender: UISlider) {
    let sliderValue = CGFloat(sender.value)
    viewAnimator.fractionComplete = sliderValue
    if viewAnimator.isRunning {
      viewAnimator.pauseAnimation()
      animationIsRunning = false
    }
  }
  
  @IBAction func handleReverseButton(_ sender: UIButton) {
    animatingBackwards = !animatingBackwards
//    viewAnimator.isReversed = !viewAnimator.isReversed
//    sender.isEnabled = false
  }
  
  @IBAction func handleStartStopButton(_ sender: UIButton) {
    
    switch viewAnimator.state {
    case .inactive:
      animationSlider.isEnabled = true
      resetButton.isEnabled = true
      reverseButton.isEnabled = true

      animationIsRunning = true
      leadingConstraint.constant = 20
      self.view.layoutIfNeeded()
      viewAnimator.addAnimations {
        [weak leadingConstraint, weak self] in
        guard let strongLeadingConstraint = leadingConstraint,
          let strongSelf = self else {
            return
        }
        strongLeadingConstraint.constant = strongSelf.view.bounds.width - strongSelf.imageView.bounds.width - 20
        strongSelf.view.layoutIfNeeded()
      }
      viewAnimator.addCompletion() {
        (animatingPosition) in
        self.handleResetButton(nil)
      }
      viewAnimator.startAnimation()
    case .active:
      reverseButton.isEnabled = true
      if viewAnimator.isRunning {
        viewAnimator.pauseAnimation()
        animationIsRunning = false
        resetButton.isEnabled = true
      } else {
        viewAnimator.startAnimation()
        animationIsRunning = true
        
      }

    case .stopped:
      viewAnimator.startAnimation()
      animationIsRunning = true
    }

  }
  
  @IBAction func handleResetButton(_ sender: UIButton?) {
    resetButton.isEnabled = false
    viewAnimator.stopAnimation(true)
    reverseButton.isEnabled = false
    animationSlider.isEnabled = false
    animationIsRunning = false
    leadingConstraint.constant = 20
    animationSlider.value = 0.0
    view.layoutIfNeeded()
    animatingBackwards = false
  }
}
