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
