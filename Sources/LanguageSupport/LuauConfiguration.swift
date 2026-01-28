//
//  LuauConfiguration.swift
//
//  Luau language configuration
//

import Foundation
import RegexBuilder


private let luauReservedIdentifiers = [
  "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
  "if", "in", "local", "nil", "not", "or", "repeat", "return", "then",
  "true", "until", "while",

  // Luau extensions / Roblox specifics
  "continue", "export", "type", "typeof"
]

private let luauReservedOperators = [
  "+", "-", "*", "/", "%", "^", "#",
  "==", "~=", "<=", ">=", "<", ">",
  "=", "(", ")", "{", "}", "[", "]",
  ";", ":", ",", ".", "..", "..."
]


extension LanguageConfiguration {

  /// Language configuration for Roblox LuaU
  public static func luau(_ languageService: LanguageService? = nil) -> LanguageConfiguration {

    let numberRegex: Regex<Substring> = Regex {
      optNegation
      ChoiceOf {
        Regex { /0[xX]/; hexalLit }                 // hex
        Regex { decimalLit; "."; decimalLit }       // float
        Regex { decimalLit }                        // int
      }
    }

    let identifierRegex: Regex<Substring> = Regex {
      CharacterClass(
        ("a"..."z"),
        ("A"..."Z"),
        "_"
      )
      ZeroOrMore {
        CharacterClass(
          ("a"..."z"),
          ("A"..."Z"),
          ("0"..."9"),
          "_"
        )
      }
    }

    let operatorRegex: Regex<Substring> = Regex {
      ChoiceOf {
        "..."
        ".."
        "=="
        "~="
        "<="
        ">="
        Regex {
          CharacterClass(.anyOf("+-*/%^#=<>;:,.(){}[]"))
        }
      }
    }

    return LanguageConfiguration(
      name: "LuaU",
      supportsSquareBrackets: true,
      supportsCurlyBrackets: true,
      stringRegex: Regex {
        ChoiceOf {
          // double quoted
          Regex { "\""; ZeroOrMore { ChoiceOf { /\\./; CharacterClass(.anyOf("\"").inverted) } }; "\"" }
          // single quoted
          Regex { "'";  ZeroOrMore { ChoiceOf { /\\./; CharacterClass(.anyOf("'").inverted)  } }; "'"  }
          // long strings [[ ... ]] or [=[ ... ]=]
          Regex {
            "["
            ZeroOrMore { "=" }
            "["
            ZeroOrMore(.any, .reluctant)
            "]"
            ZeroOrMore { "=" }
            "]"
          }
        }
      },
      characterRegex: nil,
      numberRegex: numberRegex,
      singleLineComment: "--",
      nestedComment: (open: "--[[", close: "]]"),
      identifierRegex: identifierRegex,
      operatorRegex: operatorRegex,
      reservedIdentifiers: luauReservedIdentifiers,
      reservedOperators: luauReservedOperators,
      languageService: languageService
    )
  }
}
