# AshToonEx Basic Example
#
# This example demonstrates basic usage of AshToonEx with
# Ash.Resource and Ash.TypedStruct
#
# To run: mix run examples/basic.exs

# Define a simple Ash Resource with AshToonEx extension
defmodule User do
  use Ash.Resource,
    extensions: [AshToonEx.Resource]

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :email, :string, public?: true
    attribute :age, :integer, public?: true
    attribute :secret, :string, sensitive?: true
  end

  # Configure TOON encoding
  toon do
    # Only pick specific fields
    pick [:name, :email, :age]
    # Remove nil values
    compact true
    # Merge additional data
    merge %{type: "user"}
  end
end

# Define a TypedStruct with AshToonEx extension
defmodule Profile do
  use Ash.TypedStruct,
    extensions: [AshToonEx.TypedStruct]

  typed_struct do
    field :bio, :string
    field :location, :string
    field :website, :string
  end

  toon do
    compact true
    rename bio: "Bio"
  end
end

IO.puts("=== Basic AshToonEx Example ===\n")

# Create a User resource
user = %User{
  id: "123e4567-e89b-12d3-a456-426614174000",
  name: "Alice",
  email: "alice@example.com",
  age: 30,
  secret: "hidden"
}

IO.puts("Original User struct:")
IO.inspect(user)

IO.puts("\nEncoded as TOON:")
encoded = ToonEx.encode!(user)
IO.puts(encoded)

IO.puts("\n--- Using AshToonEx.Protocol ---")
fields = AshToonEx.Protocol.get_fields(user)
IO.inspect(fields)

IO.puts("\n=== TypedStruct Example ===\n")

profile = %Profile{
  bio: "Elixir developer",
  location: "San Francisco",
  website: nil
}

IO.puts("Original Profile struct:")
IO.inspect(profile)

IO.puts("\nEncoded as TOON:")
encoded_profile = ToonEx.encode!(profile)
IO.puts(encoded_profile)

IO.puts("\n=== Done! ===")
