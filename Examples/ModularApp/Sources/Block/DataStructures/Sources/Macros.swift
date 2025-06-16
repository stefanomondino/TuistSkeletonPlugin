import DataStructuresMacro

//typealias Key = ExtensibleIdentifier<String, String>



struct Key2: ExtensibleIdentifierType, ExpressibleByStringInterpolation {
    let value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    @Case static var test: Self
    @Case("ciao") static var test2: Self
}



