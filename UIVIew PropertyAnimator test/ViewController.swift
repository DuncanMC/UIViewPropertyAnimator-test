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
  
  @IBOutlet weak var centerConstraint: NSLayoutConstraint!
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
      reverseButton.isEnabled = viewAnimator.state == .active && !viewAnimator.isRunning
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
  }
  
  @IBAction func handleStartStopButton(_ sender: UIButton) {
    
    switch viewAnimator.state {
    case .inactive:
      animationSlider.isEnabled = true
      resetButton.isEnabled = true
      reverseButton.isEnabled = true

      animationIsRunning = true
      centerConstraint.constant = 30
      self.view.layoutIfNeeded()
      viewAnimator.addAnimations {
        [weak centerConstraint, weak self] in
        guard let strongCenterConstraint = centerConstraint,
          let strongSelf = self else {
            return
        }
        strongCenterConstraint.constant = strongSelf.view.bounds.width - 30
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
        reverseButton.isEnabled = !animatingBackwards
        animationIsRunning = true
        
      }

    case .stopped:
      viewAnimator.startAnimation()
      animationIsRunning = true
    }

  }
  
  @IBAction func handleResetButton(_ sender: UIButton?) {
    animatingBackwards = false
    resetButton.isEnabled = false
    viewAnimator.stopAnimation(true)
    reverseButton.isEnabled = false
    animationSlider.isEnabled = false
    animationIsRunning = false
    centerConstraint.constant = 30
    animationSlider.value = 0.0
    view.layoutIfNeeded()
  }
}
