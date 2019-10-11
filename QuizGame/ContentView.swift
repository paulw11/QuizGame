//
//  ContentView.swift
//  QuizGame
//
//  Created by Paul Wilkinson on 17/9/19.
//  Copyright © 2019 Paul Wilkinson. All rights reserved.
//

import SwiftUI

struct Heading: ViewModifier {
	func body(content: Content) -> some View {
		content.font(.headline).foregroundColor(.white)
	}
}

struct ButtonAppearance: ViewModifier {
	func body(content: Content) -> some View {
		content.font(.body).foregroundColor(Color(UIColor.label)).background(Color.blue)
	}
}
struct ContentView: View {
	
	@State private var difficulty = 0
	var body: some View {
		ZStack {
			Color.black.edgesIgnoringSafeArea(.all)
			
			VStack {
				
				Text("Difficulty").modifier(Heading())
				HStack(spacing: 40) {
					Button(action: {} ) {
						Text("All")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("Easy")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("Medium")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("Hard")
					}.modifier(ButtonAppearance())
				}.foregroundColor(Color.white)
				Text("Categories").modifier(Heading())
				HStack(spacing: 40) {
					Button(action: {} ) {
						Text("All")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("Music")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("TV")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("Science")
					}.modifier(ButtonAppearance())
					
				}
				Text("Duration").modifier(Heading())
				HStack(spacing: 40) {
					Button(action: {} ) {
						Text("5 questions")
					}
					.modifier(ButtonAppearance())
					Button(action: {} ) {
						Text("10 questions")
					}.modifier(ButtonAppearance())
					
					Button(action: {} ) {
						Text("20 questions")
					}.modifier(ButtonAppearance())
				}
			}
		}.padding(.all)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
