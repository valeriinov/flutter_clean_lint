// Prose comment without code
// This comment explains something.

/// A doc comment example
/// Another line of docs.

// TODO: this is a todo comment
// NOTE: this is a note comment

// Looks like code but missing semicolon - should not lint
// y = 3

// Looks like code but missing brace - should not lint
// if (false)


/** Multi-line doc */

// INFO: This should be ignored

// FIXME: fix later

// HACK: temporary hack

// USAGE: call foo() first

// Looks like variable but no semicolon
// int a = 3

// Looks like if without brace
// if (true)

// Looks like function without body
// void bar()

/* Not code comment */

/* TODO: fix inside */
