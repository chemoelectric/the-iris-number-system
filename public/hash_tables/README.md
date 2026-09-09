# Self-Resizing Generic Hash Table in Ada 2022

A generic hash table implemented in Ada 2022 with automatic capacity expansion and contraction:
- **Expansion**: Automatically doubles bucket capacity when element load reaches the configured expansion threshold (default: 100% load factor).
- **Contraction**: Automatically halves bucket capacity when element load falls below the configured shrink threshold (default: 25% load factor), bounded by the initial minimum capacity.
- **Style**: Conforms strictly to Ada 2022 lowercase standards, maximum 72-column lines, formal subprogram contracts (`pre`/`post`), structured `while` control loops, and zero memory leaks.

Run tests with:
`make test`
