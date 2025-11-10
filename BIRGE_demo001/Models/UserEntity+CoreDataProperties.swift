//
//  UserEntity+CoreDataProperties.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
//

public import Foundation
public import CoreData


public typealias UserEntityCoreDataPropertiesSet = NSSet

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "User")
    }

    @NSManaged public var avgRating: Double
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isVerified: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var passwordHash: String?
    @NSManaged public var phone: String?
    @NSManaged public var registrationDate: Date?
    @NSManaged public var userType: String?
    @NSManaged public var booking: NSSet?

}

// MARK: Generated accessors for booking
extension UserEntity {

    @objc(addBookingObject:)
    @NSManaged public func addToBooking(_ value: BookingEntity)

    @objc(removeBookingObject:)
    @NSManaged public func removeFromBooking(_ value: BookingEntity)

    @objc(addBooking:)
    @NSManaged public func addToBooking(_ values: NSSet)

    @objc(removeBooking:)
    @NSManaged public func removeFromBooking(_ values: NSSet)

}

extension UserEntity : Identifiable {

}
