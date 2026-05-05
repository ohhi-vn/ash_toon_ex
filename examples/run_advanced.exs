# AshToonEx Advanced Example
#
# This example demonstrates advanced features:
# - Using AshToonEx with Ash Resources
# - Using AshToonEx.Protocol
# - ToonEx.Fragment usage
# - Phoenix integration helpers
#
# To run: mix run examples/run_advanced.exs

IO.puts("=== Advanced AshToonEx Example ===\n")

# Example 1: Simple map with ToonEx.Fragment
IO.puts("1. Using ToonEx.Fragment:")
fragment = %ToonEx.Fragment{
  encode: fn _opts -> "custom: data\nnested: true" end
}
map_with_fragment = %{
  id: "123",
  embedded: fragment
}
IO.puts(ToonEx.encode!(map_with_fragment))
IO.puts("")

# Example 2: Complex nested structures
IO.puts("2. Complex nested structures:")
nested = %{
  user: %{
    name: "Bob",
    roles: ["admin", "user"],
    meta: %{created: "2024-01-01"}
  }
}
IO.puts(ToonEx.encode!(nested))
IO.puts("")

# Example 3: Demonstrate AshToonEx.Helpers
IO.puts("3. AshToonEx.Helpers:")
IO.puts("Version: #{AshToonEx.version()}")
IO.puts("")

# Example 4: Phoenix Serializer
IO.puts("4. Phoenix Serializer:")
IO.puts("Encode: #{AshToonEx.Phoenix.ToonSerializer.encode(%{name: "Alice", age: 30})}")
IO.puts("Decode: #{inspect(AshToonEx.Phoenix.ToonSerializer.decode("name: Alice\nage: 30"))}")
IO.puts("")

# Example 5: Simulate Phoenix response
IO.puts("5. Simulating Phoenix controller response:")
IO.puts("Content-Type: application/x-toon")
IO.puts("Body: #{ToonEx.encode!(%{id: "123", type: "user", name: "Charlie"})}")
IO.puts("")

IO.puts("=== Done! ===")
IO.puts("\nNote: For full examples with Ash Resources, relationships, calculations,")
IO.puts("and aggregates, see the test files in test/ash_toon_ex_test.exs")
