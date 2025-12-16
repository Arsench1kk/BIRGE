//
//  RideEntity+CoreDataProperties.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
//

import Foundation
import CoreData


public typealias RideEntityCoreDataPropertiesSet = NSSet

extension RideEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RideEntity> {
        return NSFetchRequest<RideEntity>(entityName: "Ride")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var currentPassengers: Int32
    @NSManaged public var departureAddress: String?
    @NSManaged public var destinationAddress: String?
    @NSManaged public var estimatedDuration: Int32
    @NSManaged public var groupDiscountPercent: Double
    @NSManaged public var maxPassengers: Int32
    @NSManaged public var rideId: UUID?
    @NSManaged public var rideName: String?
    @NSManaged public var scheduledTime: Date?
    @NSManaged public var status: String?
    @NSManaged public var creator: UserEntity?
    @NSManaged public var driver: UserEntity?
    @NSManaged public var booking: NSSet?

}

// MARK: Generated accessors for booking
extension RideEntity {

    @objc(addBookingObject:)
    @NSManaged public func addToBooking(_ value: BookingEntity)

    @objc(removeBookingObject:)
    @NSManaged public func removeFromBooking(_ value: BookingEntity)

    @objc(addBooking:)
    @NSManaged public func addToBooking(_ values: NSSet)

    @objc(removeBooking:)
    @NSManaged public func removeFromBooking(_ values: NSSet)

}

extension RideEntity : Identifiable {

}
