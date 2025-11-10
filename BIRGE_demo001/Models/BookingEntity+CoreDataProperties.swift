//
//  BookingEntity+CoreDataProperties.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
//

public import Foundation
public import CoreData


public typealias BookingEntityCoreDataPropertiesSet = NSSet

extension BookingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookingEntity> {
        return NSFetchRequest<BookingEntity>(entityName: "Booking")
    }

    @NSManaged public var bookingId: UUID?
    @NSManaged public var bookingStatus: String?
    @NSManaged public var bookingTime: Date?
    @NSManaged public var passengerCount: Int32
    @NSManaged public var pickupLat: Double
    @NSManaged public var pickupLng: Double
    @NSManaged public var pickupLocation: String?
    @NSManaged public var specialRequests: String?
    @NSManaged public var passenger: UserEntity?
    @NSManaged public var ride: RideEntity?

}

extension BookingEntity : Identifiable {

}
