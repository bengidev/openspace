//
//  SpacerPetScenePalette.swift
//  OpenSpace
//

import UIKit

struct SpacerPetScenePalette {
    let shell: UIColor
    let side: UIColor
    let rear: UIColor
    let top: UIColor
    let under: UIColor
    let facePlate: UIColor
    let faceGlass: UIColor
    let edge: UIColor
    let foot: UIColor
    let accent: UIColor
    let cheek: UIColor
    let highlight: UIColor

    static let eye = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
    static let mouth = UIColor(red: 0.36, green: 0.35, blue: 0.33, alpha: 1)
    static let accentEye = UIColor(red: 0.93, green: 0.42, blue: 0.14, alpha: 1)

    init(isDark: Bool) {
        if isDark {
            shell = UIColor(red: 0.54, green: 0.51, blue: 0.47, alpha: 1)
            side = UIColor(red: 0.39, green: 0.36, blue: 0.33, alpha: 1)
            rear = UIColor(red: 0.3, green: 0.28, blue: 0.26, alpha: 1)
            top = UIColor(red: 0.62, green: 0.59, blue: 0.54, alpha: 1)
            under = UIColor(red: 0.32, green: 0.3, blue: 0.28, alpha: 1)
            facePlate = UIColor(red: 0.58, green: 0.55, blue: 0.5, alpha: 1)
            faceGlass = UIColor(red: 0.64, green: 0.6, blue: 0.54, alpha: 0.32)
            edge = UIColor(red: 0.43, green: 0.4, blue: 0.36, alpha: 1)
            foot = UIColor(red: 0.42, green: 0.39, blue: 0.36, alpha: 1)
            accent = UIColor(red: 0.74, green: 0.29, blue: 0.1, alpha: 1)
            cheek = UIColor(red: 0.68, green: 0.31, blue: 0.14, alpha: 0.66)
            highlight = UIColor(red: 0.65, green: 0.62, blue: 0.56, alpha: 1)
        } else {
            shell = UIColor(red: 0.86, green: 0.84, blue: 0.79, alpha: 1)
            side = UIColor(red: 0.67, green: 0.64, blue: 0.59, alpha: 1)
            rear = UIColor(red: 0.58, green: 0.55, blue: 0.5, alpha: 1)
            top = UIColor(red: 0.91, green: 0.89, blue: 0.84, alpha: 1)
            under = UIColor(red: 0.61, green: 0.58, blue: 0.53, alpha: 1)
            facePlate = UIColor(red: 0.89, green: 0.87, blue: 0.82, alpha: 1)
            faceGlass = UIColor(red: 0.94, green: 0.91, blue: 0.85, alpha: 0.3)
            edge = UIColor(red: 0.55, green: 0.52, blue: 0.48, alpha: 1)
            foot = UIColor(red: 0.6, green: 0.57, blue: 0.52, alpha: 1)
            accent = UIColor(red: 0.78, green: 0.3, blue: 0.08, alpha: 1)
            cheek = UIColor(red: 0.82, green: 0.38, blue: 0.14, alpha: 0.66)
            highlight = UIColor(red: 0.92, green: 0.9, blue: 0.85, alpha: 1)
        }
    }
}
