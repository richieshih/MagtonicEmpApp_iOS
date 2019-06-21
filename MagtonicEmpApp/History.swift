//
//  History.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/6/11.
//  Copyright © 2019 richie shih. All rights reserved.
//

import Foundation

class History {
    var code: String
    var desc: String
    var date: String
    var time: String
    var latitude: Double
    var longtitude: Double
    
    init(code: String, desc: String, date: String, time: String, latitude: Double, longtitude: Double) {
        
        self.code = code
        self.desc = desc
        self.date = date
        self.time = time
        self.latitude = latitude
        self.longtitude = longtitude
    }
    
    func getCode() -> String {
        return code
    }
    
    func setCode(code: String) {
        self.code = code
    }
    
    func getDesc() -> String {
        return desc
    }
    
    func setDesc(desc: String) {
        self.desc = desc
    }
    
    func getDate() -> String {
        return date
    }
    
    func setDate(date: String) {
        self.date = date
    }
    
    func getTime() -> String {
        return time
    }
    
    func setTime(time: String) {
        self.time = time
    }
    
    func getLatitude() -> Double {
        return latitude
    }
    
    func setLatitude(latitude: Double) {
        self.latitude = latitude
    }
    
    func getLongitude() -> Double {
        return longtitude
    }
    
    func setLongitude(longitude: Double) {
        self.longtitude = longitude
    }
}
