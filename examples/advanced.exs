# AshToonEx Advanced Example
#
# This example demonstrates advanced features:
# - Relationships (has_many, belongs_to)
# - Calculations
# - Aggregates
# - Phoenix integration helpers
# - Customize with ToonEx.Fragment
# - Complex nested structures

Mix.install([
  {:ash, "~> 3.24"},
  {:toon_ex, "~> 1.1"},
  {:ash_toon_ex, path: "."}
])

# Define a domain for our resources
defmodule MyApp.Domain do
  use Ash.Domain
end

# Define a Post resource with relationships
defmodule MyApp.Post do
  use Ash.Resource,
    domain: MyApp.Domain,
    extensions: [AshToonEx.Resource]

  attributes do
    uuid_primary_key :id
    attribute :title, :string, public?: true
    attribute :content, :string, public?: true
    attribute :published, :boolean, public?: true, default: false
  end

  relationships do
    belongs_to :author, MyApp.User
    has_many :comments, MyApp.Comment
  end

  calculations do
    calculate :slug, :string,
      expr: String.replace(title, " ", "-") |> String.downcase()
  end

  aggregates do
    count :comment_count, :comments
  end

  # Advanced TOON configuration
  toon do
    # Include relationships, calculations, and aggregates
    pick %{
      relationships?: true,
      calculations?: true,
      aggregates?: true
    }

    # Compact output
    compact true

    # Merge metadata
    merge %{type: "post"}

    # Rename for API compatibility
    rename title: "Title", content: "Content"

    # Order keys
    order ["Title", "Content", "comment_count", "type"]
  end
end

# Define a Comment resource
defmodule MyApp.Comment do
  use Ash.Resource,
    domain: MyApp.Domain,
    extensions: [AshToonEx.Resource]

  attributes do
    uuid_primary_key :id
    attribute :body, :string, public?: true
    attribute :author_name, :string, public?: true
  end

  relationships do
    belongs_to :post, MyApp.Post
  end

  toon do
    compact true
    pick [:body, :author_name]
    merge %{type: "comment"}
  end
end

# Define a User resource with sensitive data
defmodule MyApp.User do
  use Ash.Resource,
    domain: MyApp.Domain,
    extensions: [AshToonEx.Resource]

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :email, :string, public?: true
    attribute :password_hash, :string, sensitive?: true
    attribute :role, :string, public?: true, default: "user"
  end

  relationships do
    has_many :posts, MyApp.Post
  end

  calculations do
    calculate :display_name, :string, expr: name
  end

  toon do
    # Don't include sensitive fields by default
    pick %{calculations?: true}

    compact true

    # Use customize for complex logic
    customize fn result, record ->
      # Add a computed field based on record
      result = List.keystore(result, :is_admin, 0, {:is_admin, record.role == "admin"})

      # Add a ToonEx.Fragment for pre-encoded data
      fragment = %ToonEx.Fragment{
        encode: fn _opts -> "metadata: \"custom-encoded\"" end
      }
      List.keystore(result, :metadata, 0, {:metadata, fragment})
    end

    merge %{api_version: "1.0"}

    order [:name, :display_name, :is_admin, :api_version]
  end
end

# Example usage
IO.puts("=== Advanced AshToonEx Example ===\n")

# Create sample data
user = %MyApp.User{
  id: "user-123",
  name: "Bob Smith",
  email: "bob@example.com",
  password_hash: "hashed_secret",
  role: "user"
}

post = %MyApp.Post{
  id: "post-456",
  title: "Advanced AshToonEx Features",
  content: "This is the content...",
  published: true,
  author: user,
  slug: "advanced-ashtoonex-features",
  comment_count: 5
}

comment = %MyApp.Comment{
  id: "comment-789",
  body: "Great post!",
  author_name: "Alice",
  post: post
}

IO.puts("--- User (with sensitive fields hidden) ---")
IO.puts(ToonEx.encode!(user))
IO.puts("")

IO.puts("--- Post (with relationships, calculations, aggregates) ---")
IO.puts(ToonEx.encode!(post))
IO.puts("")

IO.puts("--- Comment ---")
IO.puts(ToonEx.encode!(comment))
IO.puts("")

IO.puts("--- Using AshToonEx.Protocol ---")
IO.puts("User fields:")
IO.inspect(AshToonEx.Protocol.get_fields(user))

IO.puts("\n--- Phoenix Integration Example ---")
IO.puts("Simulating Phoenix controller response:")

# Simulate Phoenix response
conn = %{
  assigns: %{resource: post},
  resp_headers: []
}

# In a real Phoenix app, you would do:
# conn
# |> put_resp_content_type("application/x-toon")
# |> send_resp(200, ToonEx.encode!(post))

response_toon = ToonEx.encode!(conn.assigns.resource)
IO.puts("Response body (TOON):")
IO.puts(response_toon)
IO.puts("Content-Type: application/x-toon")

IO.puts("\n--- Customize with Fragment ---")
IO.puts("The User TOON above includes a 'metadata' field that was pre-encoded as a Fragment")

IO.puts("\n=== Done! ===")
