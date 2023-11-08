//
//  ViewController.swift
//  UIVIew PropertyAnimator test
//
//  Created by Duncan Champney on 12/7/16.
//  Copyright © 2016 Duncan Champney. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

  var useSpringAnimation = true

  let margin: CGFloat =             30.00
  var animationDuration =            1.0
  var springDampingRatio: CGFloat =  0.30 {
    didSet {
      dampingFactorLabel.text = String(format: "%.02f", springDampingRatio)
      dampingFactorSlider.value = Float(springDampingRatio)
    }
  }

  //MARK: - IBOutlets
  
  ///This constraint controls the center x of the image view we're animating
  @IBOutlet weak var centerConstraint: NSLayoutConstraint!
  @IBOutlet weak var animationSlider: UISlider!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var reverseButton: UIButton!
  @IBOutlet weak var animationDirectionLabel: UILabel!
  @IBOutlet weak var dampingFactorLabel: UILabel!
  @IBOutlet weak var dampingFactorSlider: UISlider!
  @IBOutlet weak var useSpringAnimationSwitch: UISwitch!
  //MARK: - Properties
  
  var viewAnimator: UIViewPropertyAnimator?

  ///This property keeps track of whether we're animating backwards or forwards
  var animatingBackwards: Bool = false {
    didSet {
      viewAnimator?.isReversed = animatingBackwards
      if let viewAnimator = viewAnimator {
        reverseButton.isEnabled = viewAnimator.state == .active && !viewAnimator.isRunning
      } else {
        reverseButton.isEnabled = false
      }
        
      if animatingBackwards {
        animationDirectionLabel.text = NSLocalizedString("Backward", comment: "")
      } else {
        animationDirectionLabel.text = NSLocalizedString("Forward", comment: "")
      }
    }
  }
  

  var animationIsRunning = false {
    didSet {
      if animationIsRunning {
        startStopButton.setTitle(NSLocalizedString("Pause", comment: ""), for: .normal)
        startTimer(true)
      } else {
        startStopButton.setTitle(NSLocalizedString("Start", comment: ""), for: .normal)
        startTimer(false)
      }
      let canAdjustDamping = !animationIsRunning &&
        viewAnimator?.state != .active &&
        viewAnimator?.state != .stopped
      
      useSpringAnimationSwitch.isEnabled = canAdjustDamping
      dampingFactorSlider.isEnabled = canAdjustDamping
    }
  }
  
  
  weak var timer: Timer?
  
  //MARK: - Overridden instance methods
  
  override func viewWillDisappear(_ animated: Bool) {
    startTimer(false) //make sure our timer isn't running when we leave this ViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupAnimator()
    viewAnimator?.isInterruptible = true
    springDampingRatio = 0.3
  }

  //MARK: - Custom Instance Methods
  
  func setupAnimator() {
    if useSpringAnimation {
      print("Using spring damping")
      viewAnimator = UIViewPropertyAnimator(duration: animationDuration,
                                            dampingRatio: springDampingRatio)
    } else {
      print("Using ease in/out animation")
      viewAnimator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut)
    }
  }
  
  func startTimer(_ start: Bool) {
    if start {
      timer = Timer.scheduledTimer(withTimeInterval: 0.02,
                                   repeats: true) {
                                    timer in
                                    var value = Float(self.viewAnimator?.fractionComplete ?? 0.0)
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

  @IBAction func handleDampingSlider(_ sender: UISlider) {
    springDampingRatio = CGFloat(dampingFactorSlider.value)
    viewAnimator = nil
  }
  
  @IBAction func handleDampingSwitch(_ sender: UISwitch) {
    useSpringAnimation = useSpringAnimationSwitch.isOn
    setupAnimator()
  }
  
  @IBAction func handleSlider(_ sender: UISlider) {
    let sliderValue = CGFloat(sender.value)
    viewAnimator?.fractionComplete = sliderValue
    if viewAnimator?.isRunning ?? false {
      viewAnimator?.pauseAnimation()
      animationIsRunning = false
    }
  }
  
  @IBAction func handleReverseButton(_ sender: UIButton) {
    animatingBackwards = !animatingBackwards
  }
  
  @IBAction func handleStartStopButton(_ sender: UIButton) {
    
    if  viewAnimator == nil {
      setupAnimator()
    }
    if let viewAnimator = viewAnimator {
      switch viewAnimator.state {
      case .inactive:
        animationSlider.isEnabled = true
        resetButton.isEnabled = true
        reverseButton.isEnabled = true
        
        animationIsRunning = true
        centerConstraint.constant = margin
        self.view.layoutIfNeeded()
        viewAnimator.addAnimations {
          [weak centerConstraint, weak self] in
          guard let strongCenterConstraint = centerConstraint,
            let strongSelf = self else {
              return
          }
          strongCenterConstraint.constant = strongSelf.view.center.y
          strongSelf.view.layoutIfNeeded()
        }
        viewAnimator.addCompletion() {
          (animatingPosition) in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.handleResetButton(nil)
          }
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
  }
  
  @IBAction func handleResetButton(_ sender: UIButton?) {
    animatingBackwards = false
    resetButton.isEnabled = false
    viewAnimator?.stopAnimation(true)
    reverseButton.isEnabled = false
    animationSlider.isEnabled = false
    animationIsRunning = false
    centerConstraint.constant = margin
    UIView.animate(withDuration: 0.2){
      self.view.layoutIfNeeded()
    }
    animationSlider.value = 0.0
    view.layoutIfNeeded()
  }
}
