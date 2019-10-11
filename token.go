package main

// Token type
type Token int

const (
	// ILLEGAL is illegal
	ILLEGAL Token = iota

	// EOF is eof
	EOF

	// WS is ws
	WS

	// IDENT is an identifier
	IDENT

	// POUND is a pound
	POUND

	// COLON is a colon
	COLON

	// SEMICOLON is a semicolon
	SEMICOLON
)
