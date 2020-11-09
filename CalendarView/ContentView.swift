//
//  ContentView.swift
//  CalendarView
//
//  Created by Amber Spadafora on 11/8/20.
//  Copyright © 2020 Amber Spadafora. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    //let calendar = Calendar(identifier: .gregorian)
    
    var weekdays: [Int: String] = [0:"S",
                                   1:"M",
                                   2:"T",
                                   3:"W",
                                   4:"T",
                                   5:"F",
                                   6:"S"
    ]
    
    @ObservedObject var monthFormatter = MonthFormatter(baseDate: Date())
    
    var body: some View {
        // rows
        return VStack {
            Button("Next Month"){
                self.monthFormatter.baseDate = MonthFormatter.calendar.date(byAdding: .month, value: 1, to: self.monthFormatter.baseDate) ?? Date()
                
            }
            Text("")
            HStack {
                ForEach(0..<7) { num in
                    Text(self.weekdays[num] ?? "").frame(width: 50)
                }
            }
            
            ForEach(0..<self.monthFormatter.displayMonth.count) { week in
                HStack {
                    // columns
                    ForEach(0..<7) { day in
                        if self.monthFormatter.displayMonth[week][day].isWithinDisplayedMonth {
                            Text("<3").frame(width: 50, height: 50)
                        } else {
                            Text("").frame(width: 50, height: 50)
                        }
                        
                    }
                }
            }
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


