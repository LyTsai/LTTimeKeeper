//
//  ViewController.swift
//  Swift1_timeKeeper_codeOnly
//
//  Created by Lydire on 16/3/30.
//  Copyright © 2016年 LyTsai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var timeLabel : UILabel!
    var timeButtons : [UIButton]!
    var startButton : UIButton!
    var resetButton : UIButton!
    var timer : NSTimer?
    var signButton : UIButton!
    
    var isCounting : Bool = false {
        willSet{
            if newValue {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: ("updateTimer:"), userInfo: nil, repeats: true)
            }else {
                timer?.invalidate()
                timer = nil
            }
            setSettingButtonEnabled(!newValue)
        }
    }
    
    var remainingSeconds : Int = 0 {
        willSet {
            let min = newValue / 60
            let sec = newValue % 60
            timeLabel.text = String(format: "%02d : %02d",min,sec)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimeLabel()
        setupTimeButtons()
        setupActionButtons()
        setupSignButton()
    }
    
    //frame统一写到后面的布局里了，view直接调用，self省略
    func setupTimeLabel(){
        timeLabel = UILabel()
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.font = UIFont.systemFontOfSize(80)
        timeLabel.backgroundColor = UIColor.blackColor()
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = "00 : 00"
        
        view.addSubview(timeLabel)
    }
    
    let timeButtonsInfo = [("1min",60),("3min",180),("5min",300),("sec",1)]//元祖
    func setupTimeButtons(){
        timeButtons = []
        for (title, sec) in timeButtonsInfo {
            let button = UIButton()
            button.setTitle(title, forState: .Normal)
            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
            
            button.tag = sec
            
            button.addTarget(self, action: Selector("timeButtonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            view.addSubview(button)
            timeButtons.append(button)
        }
    }
    
    func setupActionButtons(){
        startButton = UIButton()
        startButton.backgroundColor = UIColor.redColor()
        startButton.setTitle("Start", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        startButton.addTarget(self, action: Selector("startButtonTapped:"), forControlEvents: .TouchUpInside)
        view.addSubview(startButton)
        
        resetButton = UIButton()
        resetButton.backgroundColor = UIColor.redColor()
        resetButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        resetButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.addTarget(self, action: Selector("resetButtonTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(resetButton)
    }
    
    func setupSignButton(){
        signButton = UIButton()
        signButton.backgroundColor = UIColor.blueColor()
        signButton.setTitle("+", forState: .Normal)
        signButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signButton.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        signButton.addTarget(self, action: Selector("changeSign"), forControlEvents: .TouchUpInside)
        
        view.addSubview(signButton)
    }

    //布局
    override func viewDidLayoutSubviews() {
        timeLabel.frame = CGRectMake(10, 40, view.bounds.size.width-20, 120)
        
        let width = view.bounds.size.width - 20 - CGFloat(timeButtons.count) * 64.0
        let gap = width / CGFloat(timeButtons.count - 1)
        
        signButton.frame = CGRectMake(view.bounds.size.width * 0.5 - 100, view.bounds.height-170, 40, 40)
    
        for (index, button) in timeButtons.enumerate() {
            let buttonLeft = 10.0 + CGFloat(index) * (64.0 + gap)
            button.frame = CGRectMake(buttonLeft, view.bounds.height - 120.0, 64, 44)
        }
        
        startButton.frame = CGRectMake(10, view.bounds.size.height - 60, view.bounds.size.width - 20 - 100, 44)
        resetButton.frame = CGRectMake(10 + startButton.frame.width + 20, startButton.frame.origin.y, 80, 44)
    }
    
    func changeSign() {
        let sign = signButton.titleLabel?.text
        sign == "+" ? signButton.setTitle("-", forState: .Normal): signButton.setTitle("+", forState: .Normal)
    }
    
    //点击事件，每段增加
    func timeButtonTapped(button : UIButton){
        if signButton.titleLabel?.text == "+" {
            remainingSeconds += button.tag
        } else {
            remainingSeconds -= button.tag
        }
    }
    
    func updateTimer(timer : NSTimer){
        remainingSeconds--
        if remainingSeconds <= 0 {
            isCounting = false
            let alertVC = UIAlertController(title: "Time is up", message: "", preferredStyle: .Alert)
            let action = UIAlertAction(title: "I Know", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                print("Tapped")
            })
            alertVC.addAction(action)
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    func setSettingButtonEnabled(enable : Bool){
        for button in timeButtons {
            button.enabled = enable
            button.alpha = enable ? 1.0 : 0.3
        }
        resetButton.enabled = enable
        resetButton.alpha = enable ? 1.0 : 0.3
        let title = enable ? "Start" : "Pause"
        startButton.setTitle(title, forState: .Normal)
    }
    
    
    func startButtonTapped(button : UIButton){
        if remainingSeconds < 0 {
            let alertVC = UIAlertController(title: "Wrong Time Set", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Reset", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.remainingSeconds = 0
            })
            alertVC.addAction(action)
            self.presentViewController(alertVC, animated: true, completion: nil)
            
            return
        }

        isCounting = !isCounting
        //消息推送
        if isCounting {
            createAndFireLocalNotificationAfterSeconds(Double(remainingSeconds))
        }else  {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    func resetButtonTapped(){
        remainingSeconds = 0
    }
    
    func createAndFireLocalNotificationAfterSeconds(seconds : NSTimeInterval){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        
        notification.fireDate = NSDate(timeIntervalSinceNow:seconds)
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.alertBody = "Time is up!"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

