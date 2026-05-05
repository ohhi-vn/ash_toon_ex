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
