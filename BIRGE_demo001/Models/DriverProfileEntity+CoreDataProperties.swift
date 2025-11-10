//
//  DriverProfileEntity+CoreDataProperties.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
//

public import Foundation
public import CoreData


public typealias DriverProfileEntityCoreDataPropertiesSet = NSSet

extension DriverProfileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DriverProfileEntity> {
        return NSFetchRequest<DriverProfileEntity>(entityName: "DriverProfile")
    }

    @NSManaged public var carModel: String?
    @NSManaged public var carPlate: String?
    @NSManaged public var currentStatus: String?
    @NSManaged public var licenseNumber: String?
    @NSManaged public var maxCapacity: Int32
    @NSManaged public var user: UserEntity?

}

extension DriverProfileEntity : Identifiable {

}
