package sle.shim;

typedef QueryResult = {
    public var result:Dynamic;    
    public var error: {
        message: String,
        stack: String
    };
}
