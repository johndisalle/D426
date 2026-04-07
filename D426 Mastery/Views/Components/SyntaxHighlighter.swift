import SwiftUI

struct SQLSyntaxText: View {
    let sql: String

    private static let keywords = Set([
        "SELECT", "FROM", "WHERE", "INSERT", "INTO", "VALUES", "UPDATE", "SET",
        "DELETE", "CREATE", "TABLE", "ALTER", "DROP", "INDEX", "VIEW", "JOIN",
        "INNER", "LEFT", "RIGHT", "FULL", "OUTER", "ON", "AND", "OR", "NOT",
        "IN", "BETWEEN", "LIKE", "IS", "NULL", "AS", "ORDER", "BY", "GROUP",
        "HAVING", "DISTINCT", "LIMIT", "OFFSET", "UNION", "ALL", "EXISTS",
        "CASE", "WHEN", "THEN", "ELSE", "END", "COUNT", "SUM", "AVG", "MIN",
        "MAX", "PRIMARY", "KEY", "FOREIGN", "REFERENCES", "CONSTRAINT", "CHECK",
        "DEFAULT", "NOT", "UNIQUE", "CASCADE", "ASC", "DESC", "ADD", "COLUMN",
        "INT", "INTEGER", "VARCHAR", "TEXT", "DATE", "DECIMAL", "BOOLEAN",
        "FLOAT", "DOUBLE", "CHAR", "TIMESTAMP", "IF", "REPLACE"
    ])

    var body: some View {
        Text(highlightedString)
            .font(.system(.body, design: .monospaced))
    }

    private var highlightedString: AttributedString {
        let tokens = tokenize(sql)
        var result = AttributedString()
        for token in tokens {
            var part = AttributedString(token.value)
            switch token.type {
            case .keyword:
                part.foregroundColor = .blue
                part.font = .system(.body, design: .monospaced).bold()
            case .string:
                part.foregroundColor = .green
            case .number:
                part.foregroundColor = .orange
            case .comment:
                part.foregroundColor = .gray
            case .plain:
                part.foregroundColor = .primary
            }
            result.append(part)
        }
        return result
    }

    private enum TokenType {
        case keyword, string, number, comment, plain
    }

    private struct Token {
        let value: String
        let type: TokenType
    }

    private func tokenize(_ input: String) -> [Token] {
        var tokens: [Token] = []
        let chars = Array(input)
        var i = 0

        while i < chars.count {
            // String literal
            if chars[i] == "'" {
                var str = "'"
                i += 1
                while i < chars.count && chars[i] != "'" {
                    str.append(chars[i])
                    i += 1
                }
                if i < chars.count { str.append(chars[i]); i += 1 }
                tokens.append(Token(value: str, type: .string))
            }
            // Comment
            else if i + 1 < chars.count && chars[i] == "-" && chars[i + 1] == "-" {
                var comment = ""
                while i < chars.count && chars[i] != "\n" {
                    comment.append(chars[i])
                    i += 1
                }
                tokens.append(Token(value: comment, type: .comment))
            }
            // Word
            else if chars[i].isLetter || chars[i] == "_" {
                var word = ""
                while i < chars.count && (chars[i].isLetter || chars[i].isNumber || chars[i] == "_") {
                    word.append(chars[i])
                    i += 1
                }
                let type: TokenType = Self.keywords.contains(word.uppercased()) ? .keyword : .plain
                tokens.append(Token(value: word, type: type))
            }
            // Number
            else if chars[i].isNumber {
                var num = ""
                while i < chars.count && (chars[i].isNumber || chars[i] == ".") {
                    num.append(chars[i])
                    i += 1
                }
                tokens.append(Token(value: num, type: .number))
            }
            // Other
            else {
                tokens.append(Token(value: String(chars[i]), type: .plain))
                i += 1
            }
        }
        return tokens
    }
}
