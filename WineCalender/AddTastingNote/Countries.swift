//
//  Countries.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/12.
//

import Foundation

enum Countries: Int, CaseIterable {
    case Italy
    case France
    case Spain
    case Germany
    case Portugal
    case Australia
    case NewZealand
    case UnitedStates
    case Chile
    case Argentina
    case SouthAfrica
    case China
    case etc

    var name: String {
        switch self {
        case .Italy: return "Italy 이탈리아"
        case .France: return "France 프랑스"
        case .Spain: return "Spain 스페인"
        case .Germany: return "Germany 독일"
        case .Portugal: return "Portugal 포르투갈"
        case .Australia: return "Australia 호주"
        case .NewZealand: return "NewZealand 뉴질랜드"
        case .UnitedStates: return "UnitedStates 미국"
        case .Chile: return "Chile 칠레"
        case .Argentina: return "Argentina 아르헨티나"
        case .SouthAfrica: return "SouthAfrica 남아공"
        case .China: return "China 중국"
        case .etc: return "이 외"
        }
    }
}
