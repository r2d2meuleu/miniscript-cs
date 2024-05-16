# /*	MiniscriptKeywords.cs

# This file defines a little Keywords class, which contains all the 
# MiniScript reserved words (break, for, etc.).  It might be useful 
# if you are doing something like syntax coloring, or want to make 
# sure some user-entered identifier isn’t going to conflict with a 
# reserved word.

# */
class_name Keywords
static all:string[] = {
    "break",
    "continue",
    "else",
    "end",
    "for",
    "function",
    "if",
    "in",
    "isa",
    "new",
    "null",
    "then",
    "repeat",
    "return",
    "while",
    "and",
    "or",
    "not",
    "true",
    "false"
}

func IsKeyword(string text) -> bool:
    return Array.IndexOf(all, text) >= 0
