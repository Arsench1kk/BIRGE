//
//  Booking+CoreDataProperties.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
//

public import Foundation
public import CoreData


public typealias BookingCoreDataPropertiesSet = NSSet

extension Booking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Booking> {
        return NSFetchRequest<Booking>(entityName: "Booking")
    }

    @NSManaged public var bookingId: UUID?
    @NSManaged public var pickupLocation: String?
    @NSManaged public var pickupLat: Double
    @NSManaged public var pickupLng: Double
    @NSManaged public var passangerCount: Int32
    @NSManaged public var bookingStatus: String?
    @NSManaged public var specialRequests: String?
    @NSManaged public var bookingTime: Date?

}

extension Booking : Identifiable {

}
