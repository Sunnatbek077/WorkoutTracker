//
//  MetricCard.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import SwiftUI

struct MetricCard: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    var isLarge: Bool = false
    
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(isLarge ? .title2 : .body)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(
                    isLarge ? .largeTitle : .title2,
                    design: .rounded,
                    weight: .bold)
                )
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.4), value: value)
            
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                
        )
    }
}
