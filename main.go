package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"strings"
)

type token int

const (
	illegal token = iota
	fin
	ws
	date
	time
	colon
	semicolon
	set
	rep
	pound
	ident
	unit
	linebreak
	star
)

func (t token) String() string {
	return [...]string{"Illegal", "End of file", "Whitespace", "Date", "Time", "Colon", "Semicolon", "Set", "Rep", "Pound", "Identifier", "Unit", "Linebreak", "Star"}[t]
}

// Scanner represents a lexical scanner.
type Scanner struct {
	r *bufio.Reader
}

// NewScanner returns a new instance of Scanner.
func NewScanner(r io.Reader) *Scanner {
	return &Scanner{r: bufio.NewReader(r)}
}

// read reads the next rune from the bufferred reader.
// Returns the rune(0) if an error occurs (or io.EOF is returned).
func (s *Scanner) read() rune {
	ch, _, err := s.r.ReadRune()
	if err != nil {
		return eof
	}
	return ch
}

// unread places the previously read rune back on the reader.
func (s *Scanner) unread() { _ = s.r.UnreadRune() }

// Scan returns the next token and literal value.
func (s *Scanner) Scan() (tok token, lit string) {
	// Read the next rune.
	ch := s.read()

	// If we see whitespace then consume all contiguous whitespace.
	// If we see a letter then consume as an ident or reserved word.
	if isWhitespace(ch) {
		s.unread()
		return s.scanWhitespace()
	} else if isLinebreak(ch) {
		return linebreak, ""
	} else if isLetter(ch) || isDigit(ch) {
		s.unread()
		return s.scanIdent()
	}

	// Otherwise read the individual character.
	switch ch {
	case eof:
		return fin, ""
	case '*':
		return star, string(ch)
	case '#':
		return pound, string(ch)
	case ';':
		return semicolon, string(ch)
	case ':':
		return colon, string(ch)
	}

	return illegal, string(ch)
}

// scanWhitespace consumes the current rune and all contiguous whitespace.
func (s *Scanner) scanWhitespace() (tok token, lit string) {
	// Create a buffer and read the current character into it.
	var buf bytes.Buffer
	buf.WriteRune(s.read())

	// Read every subsequent whitespace character into the buffer.
	// Non-whitespace characters and EOF will cause the loop to exit.
	for {
		if ch := s.read(); ch == eof {
			break
		} else if !isWhitespace(ch) {
			s.unread()
			break
		} else {
			buf.WriteRune(ch)
		}
	}

	return ws, buf.String()
}

// scanIdent consumes the current rune and all contiguous ident runes.
func (s *Scanner) scanIdent() (tok token, lit string) {
	firstCh := s.read()
	isUnit := isDigit(firstCh)

	var buf bytes.Buffer
	buf.WriteRune(firstCh)

	// Read every subsequent ident character into the buffer.
	// Non-ident characters and EOF will cause the loop to exit.
	for {
		if ch := s.read(); ch == eof {
			break
		} else if !isLetter(ch) && !isDigit(ch) && ch != '_' {
			s.unread()
			break
		} else {
			_, _ = buf.WriteRune(ch)
		}
	}

	// If the string matches a keyword then return that keyword.
	switch strings.ToUpper(buf.String()) {
	case "DATE":
		return date, buf.String()
	case "TIME":
		return time, buf.String()
	}

	if isUnit {
		return unit, buf.String()
	}

	// Otherwise return as a regular identifier.
	return ident, buf.String()
}

// isLinebreak returns true if the rune is a linebreak.
func isLinebreak(ch rune) bool { return ch == '\n' || ch == '\r' }

// isWhitespace returns true if the rune is a space, tab, or newline.
func isWhitespace(ch rune) bool { return ch == ' ' || ch == '\t' }

// isLetter returns true if the rune is a letter.
func isLetter(ch rune) bool { return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') }

// isDigit returns true if the rune is a digit.
func isDigit(ch rune) bool { return (ch >= '0' && ch <= '9') }

// eof represents a marker rune for the end of the reader.
var eof = rune(0)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

// Metadata is metadata
type Metadata struct {
	key   string
	value string
}

// Movement is a movement
type Movement struct {
	name string
}

// Notes fuck
type Notes struct {
	values []string
}

func main() {
	f, err := os.Open("./test.traindown")
	check(err)

	s := NewScanner(f)

	fmt.Println("Scanning...")

	var currentMovement strings.Builder
	var movements []Movement
	skipLine := false

	for {
		token, literal := s.Scan()

		fmt.Println(token)

		if token == fin {
			break
		}

		// If we hit a new line, reset the skip line
		if token == linebreak {
			skipLine = false
			continue
		}

		// Skip the line if we are skipping the line
		if skipLine == true {
			continue
		}

		// Set up a skip line that is turned off once linebreak is hit.
		if token == pound || token == star {
			skipLine = true
			continue
		}

		// Compose the movement name with the next few idents
		if token == ident {
			currentMovement.WriteString(literal + " ")
		}

		// We have hit the end of the name. Commit.
		if token == colon {
			name := strings.TrimRight(currentMovement.String(), " ")
			movements = append(movements, Movement{name: name})
			currentMovement.Reset()
		}
	}

	fmt.Println(movements)
	fmt.Println("Done!")
}
