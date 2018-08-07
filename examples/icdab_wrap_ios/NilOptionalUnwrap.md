# Unwrapping a Nil Optional

The Swift Programming Language is a significant step forward towards writing safe-by-default code.

A central concept within Swift is explicitly handling optionality.  In type declarations, a trailing `?` indicates the value could absent as represented by `nil`.  These types need explicit unwrapping to access the value they store.

When a value is not available at object initialization time, but later in the lifecycle of the object, then a trailing `!` is used for types that hold the value.  This means the value can be treated in code with explicit unwrapping.  It is called an explicitly unwrapped optional.

This chapter discusses problems with
