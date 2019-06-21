//
//  historyDB.swift
//  MagtonicEmpApp
//
//  Created by richie shih on 2019/6/14.
//  Copyright © 2019 richie shih. All rights reserved.
//

import Foundation

class historyDB {
    let tableName = "punchcard"
    var db :SQLiteConnect? = nil
    var historyArray = [History]()
    
    let sqliteURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
        } catch {
            fatalError("Error getting file URL from document directory.")
        }
    }()
    
    init() {
        
        print("[=== historyDB init start ===]")
        
        let sqlitePath = sqliteURL.path
        
        // 印出儲存檔案的位置
        print(sqlitePath)
        
        // SQLite 資料庫
        db = SQLiteConnect(path: sqlitePath)
        
        //create table
        
        if db != nil {
            let ret = db!.createTable(tableName, columnsInfo: [
                "id integer primary key autoincrement",
                "code text",
                "desc text",
                "date text",
                "time text",
                "latitude double",
                "longitude double"])
            
            print("[create table \"\(tableName)\" status \(ret)")
        }
        
        print("[=== historyDB init end ===]")
    }
    
    func readAll() -> [History] {
        print("[=== historyDB readAll start ===]")
        
        //clear first
        historyArray.removeAll()
        
        let statement = db!.fetch(tableName, cond: "1 == 1", order: nil)
        while sqlite3_step(statement) == SQLITE_ROW{
            
            let id = sqlite3_column_int(statement, 0)
            let code = String(cString: sqlite3_column_text(statement, 1))
            let desc = String(cString: sqlite3_column_text(statement, 2))
            let date = String(cString: sqlite3_column_text(statement, 3))
            let time = String(cString: sqlite3_column_text(statement, 4))
            let latitude = sqlite3_column_double(statement, 5)
            let longitude = sqlite3_column_double(statement, 6)
            
            let history = History(code: code, desc: desc, date: date, time: time, latitude: latitude, longtitude: longitude)
            
            historyArray.append(history)
        }
        sqlite3_finalize(statement)
        
        print("[=== historyDB readAll end ===]")
        
        return historyArray
    }
    
    func insert(history: History) -> Bool {
        print("[=== historyDB insert start ===]")
        var ret: Bool = false
        
        //let _ = mydb.insert("students",rowInfo: ["name":"'大強'","height":"178.2"])
        var code = "\'"
        code += history.code
        code += "\'"
        var desc = "\'"
        desc += history.desc
        desc += "\'"
        var date = "\'"
        date += history.date
        date += "\'"
        var time = "\'"
        time += history.time
        time += "\'"
        var latitude = "\'"
        latitude += String(history.latitude)
        latitude += "\'"
        var longitude = "\'"
        longitude += String(history.longtitude)
        longitude += "\'"
        
        
        
        ret = db!.insert(tableName, rowInfo: ["code" : code, "desc" : desc, "date" : date, "time" : time, "latitude" : latitude, "longitude" : longitude])
        
        
        
        print("insert history status: \(ret)")
        
        print("[=== historyDB insert end ===]")
        
        return ret
    }
    
    func clearAll() -> Bool {
        print("[=== historyDB clearAll start ===]")
        var ret: Bool = false
        
        //let _ = mydb.delete("students", cond: "id = 5")
        ret = db!.delete(tableName, cond: nil)
        
        print("clear all history status: \(ret)")
        
        print("[=== historyDB clearAll end ===]")
        
        return ret
    }
}
