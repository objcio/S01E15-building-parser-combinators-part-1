import Foundation

struct Parser<A> {
    typealias Stream = String.CharacterView
    let parse: (Stream) -> (A, Stream)?
}

func character(condition: @escaping (Character) -> Bool) -> Parser<Character> {
    return Parser { stream in
        guard let char = stream.first, condition(char) else {
            return nil
        }
        return (char, stream.dropFirst())
    }
}

extension Parser {
    func run(_ string: String) -> (A, String)? {
        guard let (result, remainder) = parse(string.characters) else { return nil }
        return (result, String(remainder))
    }
    
    var many: Parser<[A]> {
        return Parser<[A]> { stream in
            var result: [A] = []
            var remainder = stream
            while let (element, newRemainder) = self.parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }
            return (result, remainder)
        }
    }

    func map<T>(_ transform: @escaping (A) -> T) -> Parser<T> {
        return Parser<T> { stream in
            guard let (result, remainder) = self.parse(stream) else { return nil }
            return (transform(result), remainder)
        }
    }
}

let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })
let int = digit.many.map { characters in Int(String(characters))! }
int.run("123")
