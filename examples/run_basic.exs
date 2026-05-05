# AshToonEx Basic Example
#
# This example demonstrates basic usage of AshToonEx with
# simple maps and ToonEx encoder.
#
# To run: mix run examples/run_basic.exs

IO.puts("=== Basic AshToonEx Example ===\n")

# Example 1: Simple map encoding
IO.puts("1. Encoding a simple map to TOON:")
simple_map = %{
  name: "Alice",
  email: "alice@example.com",
  age: 30
}
IO.puts(ToonEx.encode!(simple_map))
IO.puts("")

# Example 2: Using ToonEx.Fragment
IO.puts("2. Using ToonEx.Fragment:")
fragment = %ToonEx.Fragment{
  encode: fn _opts -> "custom: data\nested: true" end
}
map_with_fragment = %{
  id: "123",
  embedded: fragment
}
IO.puts(ToonEx.encode!(map_with_fragment))
IO.puts("")

# Example 3: Demonstrate compact behavior
IO.puts("3. Compact behavior (removing nil values):")
map_with_nils = %{a: 1, b: nil, c: 2, d: nil}
IO.puts("Original: #{inspect(map_with_nils)}")
IO.puts("TOON output (all keys included by default):")
IO.puts(ToonEx.encode!(map_with_nils))
IO.puts("")

# Example 4: Complex nested structures
IO.puts("4. Complex nested structures:")
nested = %{
  user: %{
    name: "Bob",
    roles: ["admin", "user"],
    meta: %{created: "2024-01-01"}
  }
}
IO.puts(ToonEx.encode!(nested))
IO.puts("")

# Example 5: Demonstrate AshToonEx.Helpers
IO.puts("5. Using AshToonEx.Helpers (version):")
version = AshToonEx.version()
IO.puts("AshToonEx version: #{version}")
IO.puts("")

IO.puts("=== Done! ===")
