//
//  ViewController.swift
//  sleep-track
//
//  Created by Isfar Baset on 4/8/20.
//  Copyright © 2020 Isfar Baset. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    

    let healthStore = HKHealthStore()
  
    @IBOutlet var displayTimeLabel: UILabel!
    @IBOutlet weak var sleepStatusLabel: UILabel!
    @IBOutlet weak var moonStart: UIImageView!
    @IBOutlet weak var moonStop: UIImageView!
    
    var startTime = TimeInterval()
    var timer:Timer = Timer()
    var endTime = NSDate()
    var alarmTime = NSDate()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
      // The quantity type to write to the health store.
        let typesToShare: Set = [ HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKObjectType.categoryType(forIdentifier:  HKCategoryTypeIdentifier.sleepAnalysis)!
        ]
        
     healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) -> Void in if success == false {
            //Handle error. No error handling in this sample project.
                NSLog("Display not allowed")
            }
       }
        
        //allows you to click the moon to start
        let moonStartTap = UITapGestureRecognizer(target: self, action: #selector(moonStartTapFunction))
        moonStart.isUserInteractionEnabled = true
        moonStart.addGestureRecognizer(moonStartTap)
        
        //allows you to click the moon to stop
        let moonStopTap = UITapGestureRecognizer(target: self, action: #selector(moonStopTapFunction))
        moonStop.isUserInteractionEnabled = true
        moonStop.addGestureRecognizer(moonStopTap)
    }
    
    @IBAction func moonStartTapFunction(sender: UITapGestureRecognizer) {
        alarmTime = NSDate()
        if (!timer.isValid) {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
          }
        moonStart.isHidden = true;
        moonStop.isHidden = false;
    }
    
    
    @IBAction func moonStopTapFunction(sender: UITapGestureRecognizer) {
        endTime = NSDate()
        self.saveSleepAnalysis()
        self.retrieveSleepAnalysis()
        timer.invalidate()
        moonStart.isHidden = false;
        moonStop.isHidden = true;
    }
    
    
    @IBAction func start(sender: AnyObject) {
          
        alarmTime = NSDate()
        if (!timer.isValid) {
            let aSelector : Selector = #selector(ViewController.updateTime)
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
          }
          
            }
    
    @IBAction func stop(sender: AnyObject) {
         endTime = NSDate()
         self.saveSleepAnalysis()
         self.retrieveSleepAnalysis()
         timer.invalidate()
     }
    
    @objc func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
       // print(elapsedTime)
      //  print(Int(elapsedTime))
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        displayTimeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    
    
    
    func saveSleepAnalysis() {
    
    // alarmTime and endTime are NSDate objects
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
        
        // we create our new object we want to push in Health app
            let object = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.alarmTime as Date, end: self.endTime as Date)
        
        // at the end, we save it
            healthStore.save(object, withCompletion: { (success, error) -> Void in
            
            if error != nil {
                // something happened
                return
            }
            
            if success {
                print("My new data was saved in HealthKit")
                
            } else {
                // something happened again
            }
            
        })
        
        
            let object2 = HKCategorySample(type:sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: self.alarmTime as Date, end: self.endTime as Date)
                
            healthStore.save(object2, withCompletion: { (success, error) -> Void in
                    if error != nil {
                        // something happened
                        return
                    }
                    
                    if success {
                        print("My new data (2) was saved in HealthKit")
                    } else {
                        // something happened again
                    }
                    
                })
                
            }
            
        }
    
    
    
    func retrieveSleepAnalysis() {
    
    // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
        
        // Use a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // we create our query with a block completion to execute
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 30, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
            
            if error != nil {
                
                // something happened
                return
                
            }
            
            if let result = tmpResult {
                
                // do something with my data
                for item in result {
                    if let sample = item as? HKCategorySample {
                        let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                        print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                    }
                }
            }
        }
        
        // finally, we execute our query
        healthStore.execute(query)
    }


}

}
