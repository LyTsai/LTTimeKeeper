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
    var timer : Timer?
    var signButton : UIButton!
    
    var isCounting : Bool = false {
        willSet{
            if newValue {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer(_:))), userInfo: nil, repeats: true)
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
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 80)
        timeLabel.backgroundColor = UIColor.black
        timeLabel.textAlignment = NSTextAlignment.center
        timeLabel.text = "00 : 00"
        
        view.addSubview(timeLabel)
    }
    
    let timeButtonsInfo = [("1min",60),("3min",180),("5min",300),("sec",1)]//元祖
    func setupTimeButtons(){
        timeButtons = []
        for (title, sec) in timeButtonsInfo {
            let button = UIButton()
            button.setTitle(title, for: UIControlState())
            button.backgroundColor = UIColor.orange
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.setTitleColor(UIColor.black, for: .highlighted)
            
            button.tag = sec
            
            button.addTarget(self, action: #selector(ViewController.timeButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            
            view.addSubview(button)
            timeButtons.append(button)
        }
    }
    
    func setupActionButtons(){
        startButton = UIButton()
        startButton.backgroundColor = UIColor.red
        startButton.setTitle("Start", for: UIControlState())
        startButton.setTitleColor(UIColor.white, for: UIControlState())
        startButton.setTitleColor(UIColor.black, for: .highlighted)
        startButton.addTarget(self, action: #selector(ViewController.startButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(startButton)
        
        resetButton = UIButton()
        resetButton.backgroundColor = UIColor.red
        resetButton.setTitleColor(UIColor.white, for: UIControlState())
        resetButton.setTitleColor(UIColor.black, for: .highlighted)
        resetButton.setTitle("Reset", for: UIControlState())
        resetButton.addTarget(self, action: #selector(ViewController.resetButtonTapped), for: .touchUpInside)
        view.addSubview(resetButton)
    }
    
    func setupSignButton(){
        signButton = UIButton()
        signButton.backgroundColor = UIColor.blue
        signButton.setTitle("+", for: UIControlState())
        signButton.setTitleColor(UIColor.white, for: UIControlState())
        signButton.setTitleColor(UIColor.black, for: .highlighted)
        signButton.addTarget(self, action: #selector(ViewController.changeSign), for: .touchUpInside)
        
        view.addSubview(signButton)
    }

    //布局
    override func viewDidLayoutSubviews() {
        timeLabel.frame = CGRect(x: 10, y: 40, width: view.bounds.size.width-20, height: 120)
        
        let width = view.bounds.size.width - 20 - CGFloat(timeButtons.count) * 64.0
        let gap = width / CGFloat(timeButtons.count - 1)
        
        signButton.frame = CGRect(x: view.bounds.size.width * 0.5 - 100, y: view.bounds.height-170, width: 40, height: 40)
    
        for (index, button) in timeButtons.enumerated() {
            let buttonLeft = 10.0 + CGFloat(index) * (64.0 + gap)
            button.frame = CGRect(x: buttonLeft, y: view.bounds.height - 120.0, width: 64, height: 44)
        }
        
        startButton.frame = CGRect(x: 10, y: view.bounds.size.height - 60, width: view.bounds.size.width - 20 - 100, height: 44)
        resetButton.frame = CGRect(x: 10 + startButton.frame.width + 20, y: startButton.frame.origin.y, width: 80, height: 44)
    }
    
    func changeSign() {
        let sign = signButton.titleLabel?.text
        sign == "+" ? signButton.setTitle("-", for: UIControlState()): signButton.setTitle("+", for: UIControlState())
    }
    
    //点击事件，每段增加
    func timeButtonTapped(_ button : UIButton){
        if signButton.titleLabel?.text == "+" {
            remainingSeconds += button.tag
        } else {
            remainingSeconds -= button.tag
        }
    }
    
    func updateTimer(_ timer : Timer){
        remainingSeconds -= 1
        if remainingSeconds <= 0 {
            isCounting = false
            let alertVC = UIAlertController(title: "Time is up", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "I Know", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                print("Tapped")
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func setSettingButtonEnabled(_ enable : Bool){
        for button in timeButtons {
            button.isEnabled = enable
            button.alpha = enable ? 1.0 : 0.3
        }
        resetButton.isEnabled = enable
        resetButton.alpha = enable ? 1.0 : 0.3
        let title = enable ? "Start" : "Pause"
        startButton.setTitle(title, for: UIControlState())
    }
    
    
    func startButtonTapped(_ button : UIButton){
        if remainingSeconds < 0 {
            let alertVC = UIAlertController(title: "Wrong Time Set", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Reset", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.remainingSeconds = 0
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
            
            return
        }

        isCounting = !isCounting
        //消息推送
        if isCounting {
            createAndFireLocalNotificationAfterSeconds(Double(remainingSeconds))
        }else  {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    
    func resetButtonTapped(){
        remainingSeconds = 0
    }
    
    func createAndFireLocalNotificationAfterSeconds(_ seconds : TimeInterval){
        UIApplication.shared.cancelAllLocalNotifications()
        let notification = UILocalNotification()
        
        notification.fireDate = Date(timeIntervalSinceNow:seconds)
        notification.timeZone = TimeZone.current
        notification.alertBody = "Time is up!"
        UIApplication.shared.scheduleLocalNotification(notification)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

