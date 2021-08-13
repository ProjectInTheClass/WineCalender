//
//  WineVarieties.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/11.
//

import Foundation

enum WineVarieties: Int, CaseIterable, Comparable {

    case CabernetSauvignon
    case Merlot
    case Syrah
    case PinotNoir
    case CabernetFranc
    case Malbec
    case Nebbiolo
    case Sangiovese
    case Tempranillo
    case Zinfandel
    case Gamay
    case Chardonnay
    case SauvignonBlanc
    case Moscato
    case Riesling
    case CheninBalnc
    case PinotGris
    case Viognier
    case GrunerVeltliner
    case Gewurztraminer
    case Grenache
    case Cinsault
    case Grolleau
    case Vermentino
    case PinotMeunier
    case Glera
    case etc
    
    var name: String {
        switch self {
        case .CabernetSauvignon: return "Cabernet Sauvignon 카베르네 소비뇽"
        case .Merlot: return "Merlot 메를로"
        case .Syrah: return "Syrah/Shiraz 쉬라/쉬라즈"
        case .PinotNoir: return "Pinot Noir 피노누아"
        case .CabernetFranc: return "Cabernet Franc 카베르네 프랑"
        case .Malbec: return "Malbec 말벡"
        case .Nebbiolo: return "Nebbiolo 네비올로"
        case .Sangiovese: return "Sangiovese 산지오베제"
        case .Tempranillo: return "Tempranillo 템프라니요"
        case .Zinfandel: return "Zinfandel 진판델"
        case .Gamay: return "Gamay 가메"
        case .Chardonnay: return "Chardonnay 샤도네이/샤르도네"
        case .SauvignonBlanc: return "Sauvignon Blanc 소비뇽 블랑"
        case .Moscato: return "Moscato/Muscat 모스카토/뮈스카"
        case .Riesling: return "Riesling 리슬링"
        case .CheninBalnc: return "Chenin Balnc 슈냉 블랑"
        case .PinotGris: return "Pinot Gris/Pinot Grigio 피노 그리/피노 그리지오"
        case .Viognier: return "Viognier 비오니에"
        case .GrunerVeltliner: return "Gruner Veltliner 그뤼너 펠트리너"
        case .Gewurztraminer: return "Gewurztraminer 게뷔르츠트라미너"
        case .Grenache: return "Grenache/Granacha 그르나슈/가르나차"
        case .Cinsault: return "Cinsault 쌩쏘"
        case .Grolleau: return "Grolleau 그롤로"
        case .Vermentino: return "Vermentino 베르멘티노"
        case .PinotMeunier: return "Pinot Meunier 피노 뫼니에"
        case .Glera: return "Glera 글레라"
        case .etc: return "이 외"
        }
    }
    
    static func < (lhs: WineVarieties, rhs: WineVarieties) -> Bool {
        return lhs.name < rhs.name
    }
    
    static var sortedWineVarieties: [WineVarieties] {
        let sortedWineVarietiesArray = WineVarieties.allCases.sorted(by: <)
        return sortedWineVarietiesArray
    }
}
