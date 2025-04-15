struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    public var amount: Int
    public var currency: String

    private static let validCurrencies: Set<String> = ["USD", "GBP", "EUR", "CAN"]
    private static let toUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 2.0,
        "EUR": 2.0 / 3.0,
        "CAN": 0.8
    ]
    private static let fromUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 0.5,
        "EUR": 1.5,
        "CAN": 1.25
    ]
    public init(amount: Int, currency: String) {
        guard Money.validCurrencies.contains(currency) else {
            fatalError("Unsupported currency: \(currency)")
        }
        self.amount = amount
        self.currency = currency
    }
    public func convert(_ to: String) -> Money {
        guard Money.validCurrencies.contains(to) else {
            fatalError("Unsupported currency: \(to)")
        }

        if self.currency == to {
            return self
        }

        let toUSDMultiplier = Money.toUSD[self.currency] ?? 1.0
        let amountInUSD = Double(self.amount) * toUSDMultiplier

        let fromUSDMultiplier = Money.fromUSD[to] ?? 1.0
        let convertedAmount = amountInUSD * fromUSDMultiplier

        return Money(amount: Int(convertedAmount.rounded()), currency: to)
    }
    public func add(_ other: Money) -> Money {
        let convertedSelf = self.convert(other.currency)
        let totalAmount = convertedSelf.amount + other.amount
        return Money(amount: totalAmount, currency: other.currency)
    }
    public func subtract(_ other: Money) -> Money {
        let convertedSelf = self.convert(other.currency)
        let resultAmount = convertedSelf.amount - other.amount
        return Money(amount: resultAmount, currency: other.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public var title: String
    public var type: JobType

    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }

    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }

    public func calculateIncome(_ hours: Int = 2000) -> Int {
        switch type {
        case .Hourly(let rate):
            return Int(rate * Double(hours))
        case .Salary(let salary):
            return Int(salary)
        }
    }

    public func raise(byAmount amount: Double) {
        switch self.type {
        case .Hourly(let rate):
            self.type = .Hourly(rate + amount)
        case .Salary(let salary):
            self.type = .Salary(salary + UInt(amount))
        }
    }

    public func raise(byPercent percent: Double) {
        switch self.type {
        case .Hourly(let rate):
            self.type = .Hourly(rate * (1 + percent))
        case .Salary(let salary):
            let increased = Double(salary) * (1 + percent)
            self.type = .Salary(UInt(increased))
        }
    }
    public func convert() {
        switch self.type {
        case .Hourly(let rate):
            let salaryEstimate = rate * 2000
            let roundedSalary = UInt(((salaryEstimate + 999) / 1000).rounded(.down)) * 1000
            self.type = .Salary(roundedSalary)
        case .Salary(_):
            break
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public let firstName: String
    public let lastName: String
    public var age: Int

    private var _job: Job? = nil
    public var job: Job? {
        get { return _job }
        set {
            if age >= 16 {
                _job = newValue
            }
        }
    }

    private var _spouse: Person? = nil
    public var spouse: Person? {
        get { return _spouse }
        set {
            if age >= 16 {
                _spouse = newValue
            }
        }
    }

    //extra
    public init(firstName: String = "", lastName: String = "", age: Int) {
            if firstName == "" && lastName == "" {
                self.firstName = "Unknown"
                self.lastName = ""
            } else {
                self.firstName = firstName
                self.lastName = lastName
            }
            self.age = age
        }

    public func toString() -> String {
        let jobStr = job != nil ? "\(job!.type)" : "nil"
        let spouseStr = spouse != nil ? spouse!.firstName : "nil"
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobStr) spouse:\(spouseStr)]"
    }
}


////////////////////////////////////
// Family
//
public class Family {
    public var members: [Person]

    public init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil && spouse2.spouse == nil else {
            self.members = []
            return
        }

        spouse1.spouse = spouse2
        spouse2.spouse = spouse1

        self.members = [spouse1, spouse2]
    }

    public func haveChild(_ child: Person) -> Bool {
        let eligible = members[0].age >= 21 || members[1].age >= 21
        if eligible {
            self.members.append(child)
            return true
        } else {
            return false
        }
    }

    public func householdIncome() -> Int {
        var total = 0
        for person in members {
            if let job = person.job {
                total += job.calculateIncome(2000)
            }
        }
        return total
    }
}

