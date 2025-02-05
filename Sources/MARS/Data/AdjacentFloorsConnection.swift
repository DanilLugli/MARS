//
//  AdjacentFloorsConnection.swift
//  
//
//  Created by Danil Lugli on 03/10/24.
//

import Foundation

class AdjacentFloorsConnection: Connection {
    private var _targetFloor: String
    private var _targetRoom: String
    private var _altitude: Float
    
    init(name: String, targetFloor: String, targetRoom: String, altitude: Float) {
        self._targetFloor = targetFloor
        self._targetRoom = targetRoom
        self._altitude = altitude
        super.init(name: name)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _targetFloor = try container.decode(String.self, forKey: .targetFloor)
        _targetRoom = try container.decode(String.self, forKey: .targetRoom)
        _altitude = try container.decode(Float.self, forKey: .altitude)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }
    

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_targetFloor, forKey: .targetFloor)
        try container.encode(_targetRoom, forKey: .targetRoom)
        try container.encode(_altitude, forKey: .altitude)
        try super.encode(to: container.superEncoder())
    }
    
    var targetFloor: String {
        get {
            return _targetFloor
        }
        set {
            _targetFloor = newValue
        }
    }
    
    var targetRoom: String {
        get {
            return _targetRoom
        }
        set {
            _targetRoom = newValue
        }
    }
    
    var altitude: Float {
        get {
            return _altitude
        }
        set {
            _altitude = newValue
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case targetFloor
        case targetRoom
        case altitude
    }
}
