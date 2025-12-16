import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // MARK: - Session Management
    private let userDefaultsKey = "currentUserEmail"
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BIRGE_demo001")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("❌ Core Data load error: \(error)")
            }
            print("✅ Core Data loaded from: \(description.url?.absoluteString ?? "")")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var isCoreDataAvailable: Bool {
        return !persistentContainer.persistentStoreCoordinator.persistentStores.isEmpty
    }
    
    // MARK: - Safe Entity Creation with Error Handling
    func createUserEntity() -> UserEntity? {
        guard isCoreDataAvailable else {
            print("❌ Core Data not available")
            return nil
        }
        return UserEntity(context: context)
    }
    
    func createDriverProfileEntity() -> DriverProfileEntity? {
        guard isCoreDataAvailable else { return nil }
        return DriverProfileEntity(context: context)
    }
    
    func createRideEntity() -> RideEntity? {
        guard isCoreDataAvailable else { return nil }
        return RideEntity(context: context)
    }
    
    func createBookingEntity() -> BookingEntity? {
        guard isCoreDataAvailable else { return nil }
        return BookingEntity(context: context)
    }
    
    // MARK: - Save Context with Error Handling
    func saveContext() {
        guard isCoreDataAvailable, context.hasChanges else { return }
        
        do {
            try context.save()
            print("✅ Context saved successfully")
        } catch {
            print("❌ Error saving context: \(error)")
            // Rollback changes on error
            context.rollback()
        }
    }
    
    // MARK: - User Management
    func registerUser(firstName: String, lastName: String, email: String, phone: String, password: String, userType: String) -> (success: Bool, message: String) {
        // Check if user already exists
        if getUserByEmail(email) != nil {
            return (false, "User with email \(email) already exists")
        }
        
        guard let user = createUserEntity() else {
            return (false, "Failed to create user entity")
        }
        
        user.id = UUID()
        user.firstName = firstName
        user.lastName = lastName
        user.email = email.lowercased()
        user.phone = phone
        user.passwordHash = hashPassword(password)
        user.userType = userType
        user.avgRating = 5.0 // Default rating
        user.registrationDate = Date()
        user.isVerified = true
        
        // Create driver profile if driver
        if userType == "driver" {
            let driverResult = createDriverProfile(for: user)
            if !driverResult {
                context.delete(user)
                return (false, "Failed to create driver profile")
            }
        }
        
        saveContext()
        print("✅ User registered: \(email)")
        return (true, "Registration successful")
    }
    
    func createDriverProfile(for user: UserEntity) -> Bool {
        guard let driverProfile = createDriverProfileEntity() else {
            return false
        }
        
        driverProfile.licenseNumber = "TEMP_\(UUID().uuidString.prefix(8))"
        driverProfile.carModel = "Pending"
        driverProfile.carPlate = "TEMP"
        driverProfile.maxCapacity = 4
        driverProfile.currentStatus = "offline"
        driverProfile.user = user
        
        saveContext()
        return true
    }
    
    func registerDriver(firstName: String, lastName: String, email: String, phone: String, password: String, licenseNumber: String, carModel: String, carPlate: String, maxCapacity: Int) -> (success: Bool, message: String) {
        let userResult = registerUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            password: password,
            userType: "driver"
        )
        
        if !userResult.success {
            return userResult
        }
        
        guard let user = getUserByEmail(email),
              let driverProfile = getDriverProfile(for: user) else {
            return (false, "Failed to get user or driver profile")
        }
        
        driverProfile.licenseNumber = licenseNumber
        driverProfile.carModel = carModel
        driverProfile.carPlate = carPlate
        driverProfile.maxCapacity = Int32(maxCapacity)
        
        saveContext()
        return (true, "Driver registered successfully")
    }
    
    func getDriverProfile(for user: UserEntity) -> DriverProfileEntity? {
        let request: NSFetchRequest<DriverProfileEntity> = DriverProfileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to get driver profile: \(error)")
            return nil
        }
    }
    
    func authenticateUser(email: String, password: String) -> UserEntity? {
        guard let user = getUserByEmail(email.lowercased()),
              user.passwordHash == hashPassword(password) else {
            return nil
        }
        
        // Save session
        UserDefaults.standard.set(email.lowercased(), forKey: userDefaultsKey)
        return user
    }
    
    func getUserByEmail(_ email: String) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email.lowercased())
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to get user: \(error)")
            return nil
        }
    }
    
    func getAllUsers() -> [UserEntity] {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch users: \(error)")
            return []
        }
    }
    
    func getCurrentUser() -> UserEntity? {
        guard let email = UserDefaults.standard.string(forKey: userDefaultsKey) else {
            return nil
        }
        return getUserByEmail(email)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    // MARK: - Ride Management
    func createRide(creator: UserEntity, rideName: String, departure: String, destination: String, scheduledTime: Date, maxPassengers: Int) -> RideEntity? {
        guard let ride = createRideEntity() else {
            return nil
        }
        
        ride.rideId = UUID()
        ride.rideName = rideName
        ride.departureAddress = departure
        ride.destinationAddress = destination
        ride.scheduledTime = scheduledTime
        ride.maxPassengers = Int32(maxPassengers)
        ride.currentPassengers = 0
        ride.status = "waiting"
        ride.groupDiscountPercent = 15.0
        ride.estimatedDuration = 30
        ride.createdAt = Date()
        ride.creator = creator
        
        saveContext()
        return ride
    }
    
    func getAllRides() -> [RideEntity] {
        let request: NSFetchRequest<RideEntity> = RideEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "scheduledTime", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch rides: \(error)")
            return []
        }
    }
    
    func getAvailableRides() -> [RideEntity] {
        let now = Date()
        return getAllRides().filter {
            $0.status == "waiting" &&
            $0.currentPassengers < $0.maxPassengers &&
            ($0.scheduledTime ?? now) > now
        }
    }
    
    func getRidesCreatedByUser(_ user: UserEntity) -> [RideEntity] {
        let request: NSFetchRequest<RideEntity> = RideEntity.fetchRequest()
        request.predicate = NSPredicate(format: "creator == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "scheduledTime", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch user rides: \(error)")
            return []
        }
    }
    
    func deleteRide(_ ride: RideEntity) -> Bool {
        context.delete(ride)
        saveContext()
        return true
    }
    
    // MARK: - Booking Management
    func createBooking(passenger: UserEntity, ride: RideEntity, pickupLocation: String, passengerCount: Int) -> (success: Bool, booking: BookingEntity?, message: String) {
        // Validation
        guard ride.status == "waiting" else {
            return (false, nil, "This ride is no longer available")
        }
        
        let availableSeats = ride.maxPassengers - ride.currentPassengers
        guard availableSeats >= passengerCount else {
            return (false, nil, "Not enough seats available. Only \(availableSeats) seats left")
        }
        
        // Check if user already booked this ride
        if isUserBookedForRide(passenger: passenger, ride: ride) {
            return (false, nil, "You have already booked this ride")
        }
        
        guard let booking = createBookingEntity() else {
            return (false, nil, "Failed to create booking")
        }
        
        booking.bookingId = UUID()
        booking.pickupLocation = pickupLocation
        booking.pickupLat = 0.0
        booking.pickupLng = 0.0
        booking.passengerCount = Int32(passengerCount)
        booking.bookingStatus = "confirmed"
        booking.specialRequests = ""
        booking.bookingTime = Date()
        booking.passenger = passenger
        booking.ride = ride
        
        ride.currentPassengers += Int32(passengerCount)
        
        if ride.currentPassengers >= ride.maxPassengers {
            ride.status = "confirmed"
        }
        
        saveContext()
        return (true, booking, "Booking successful!")
    }
    
    func isUserBookedForRide(passenger: UserEntity, ride: RideEntity) -> Bool {
        let bookings = getBookingsForUser(passenger)
        return bookings.contains { $0.ride == ride }
    }
    
    func getBookingsForUser(_ user: UserEntity) -> [BookingEntity] {
        let request: NSFetchRequest<BookingEntity> = BookingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "passenger == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "bookingTime", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch bookings: \(error)")
            return []
        }
    }
    
    func cancelBooking(_ booking: BookingEntity) -> Bool {
        guard let ride = booking.ride else { return false }
        
        ride.currentPassengers -= booking.passengerCount
        
        if ride.currentPassengers < ride.maxPassengers && ride.status == "confirmed" {
            ride.status = "waiting"
        }
        
        booking.bookingStatus = "cancelled"
        saveContext()
        return true
    }
    
    // MARK: - Helper Methods
    private func hashPassword(_ password: String) -> String {
        return String(password.hashValue)
    }
    
    // MARK: - Demo Data
    func preloadDemoData() {
        if !getAllUsers().isEmpty {
            print("ℹ️ Demo data already exists")
            return
        }
        
        print("📦 Preloading demo data...")
        
        // Create demo passengers
        let aliaResult = registerUser(
            firstName: "Алия",
            lastName: "Нургалиева",
            email: "alia@demo.com",
            phone: "+77011234567",
            password: "password123",
            userType: "passenger"
        )
        
        let armanResult = registerUser(
            firstName: "Арман",
            lastName: "Жумабаев",
            email: "arman@demo.com",
            phone: "+77017654321",
            password: "password123",
            userType: "passenger"
        )
        
        // Create demo drivers
        let aslanResult = registerDriver(
            firstName: "Аслан",
            lastName: "Ибраев",
            email: "aslan@demo.com",
            phone: "+77012345678",
            password: "password123",
            licenseNumber: "ABC123456",
            carModel: "Toyota Camry",
            carPlate: "01ABC123",
            maxCapacity: 4
        )
        
        let gulnaraResult = registerDriver(
            firstName: "Гульнара",
            lastName: "Омарова",
            email: "gulnara@demo.com",
            phone: "+77023456789",
            password: "password123",
            licenseNumber: "DEF789012",
            carModel: "Hyundai Sonata",
            carPlate: "01DEF456",
            maxCapacity: 4
        )
        
        // Create demo rides
        if let alia = getUserByEmail("alia@demo.com") {
            let calendar = Calendar.current
            
            // Tomorrow morning
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.day! += 1
            components.hour = 8
            components.minute = 0
            let tomorrowMorning = calendar.date(from: components)!
            
            _ = createRide(
                creator: alia,
                rideName: "Университет - Дом",
                departure: "КазНУ им. Аль-Фараби",
                destination: "ЖК Нурлы Тау",
                scheduledTime: tomorrowMorning,
                maxPassengers: 3
            )
            
            // Tomorrow afternoon
            components.hour = 17
            let tomorrowAfternoon = calendar.date(from: components)!
            
            _ = createRide(
                creator: alia,
                rideName: "Работа - БЦ Алматы",
                departure: "Проспект Абылай хана",
                destination: "БЦ Алматы Тауэрс",
                scheduledTime: tomorrowAfternoon,
                maxPassengers: 2
            )
        }
        
        print("✅ Demo data loaded successfully")
    }
    
    // MARK: - Cleanup
    func deleteAllData() {
        let entities = ["User", "DriverProfile", "Ride", "Booking"]
        
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("❌ Failed to delete \(entity): \(error)")
            }
        }
        
        saveContext()
        logout()
    }
}
