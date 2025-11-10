//
//  User+CoreDataProperties.swift
//  BIRGE_demo001
//
//  Created by Арсен Абдухалық on 10.11.2025.
//
//

public import Foundation
public import CoreData


public typealias UserCoreDataPropertiesSet = NSSet

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var passwordHash: String?
    @NSManaged public var userType: String?
    @NSManaged public var avgRating: Double
    @NSManaged public var registrationDate: Date?
    @NSManaged public var isVerified: Bool

}

extension User : Identifiable {

}
