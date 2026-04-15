> ⚠️ **EXPERIMENTAL / UNDER ACTIVE DEVELOPMENT** ⚠️

# AshToonEx

Ash resource extension for implementing `ToonEx.Encoder` protocol.

Built on top of [ToonEx](https://github.com/ohhi-vn/toon_ex) — a high-performance TOON (Token-Oriented Object Notation) encoder/decoder for Elixir.

Inspired by [ash_jason](https://github.com/vonagam/ash_jason).

## Installation

Add to the deps:

```elixir
def deps do
  [
    {:ash_toon_ex, "~> 0.1.0"},
  ]
end
```

## Usage

Add `AshToonEx.Resource` to `extensions` list within `use Ash.Resource` options:

```elixir
defmodule Example.Resource do
  use Ash.Resource,
    extensions: [AshToonEx.Resource]
end
```

### Configuration

Producing a TOON object can have multiple steps:
- Picking keys from a record.
- Removing fields with unnecessary values (like nil).
- Merging some values.
- Renaming keys.
- Ordering keys.
- Customizing a result with a function.

By default only the picking step happens and it takes all non-private non-sensitive fields (attributes, relationships, aggregates, calculations) with loaded values from a record.

For adding and configuring those steps there is an optional `toon` dsl section:

```elixir
defmodule Example.Resource do
  use Ash.Resource,
    extensions: [AshToonEx.Resource]

  toon do
    # options
  end
end
```

All optional steps can be specified multiple times and are applied in the order they were defined in.

A result object on which those steps operate is a key-value list — not map, not keyword list.
- Unlike map the order is stable and guaranteed.
- Unlike keyword list it can have string keys.

#### `pick`

Keys to pick from a record and include in the result. Accepts a fixed explicit list of keys or a map with a configuration of default behaviour.

Values of `nil` / `Ash.NotLoaded` / `Ash.ForbiddenField` are omitted.

Map can have such options as:
- `private?` - Whether to pick private fields.
- `sensitive?` - Whether to pick sensitive fields.
- `include` - Keys to pick. In addition to fields.
- `exclude` - Keys not to pick.

```elixir
toon do
  # Pick only those listed keys
  pick [:only_some_field]

  # Pick non-sensitive fields
  pick %{private?: true}

  # Pick non-private fields
  pick %{sensitive?: true}

  # Pick all fields
  pick %{private?: true, sensitive?: true}

  # Pick usual but include and exclude some specific keys
  pick %{include: [:ok_private_field], exclude: [:irrelevant_public_field]}
end
```

#### `compact`

A step to remove unneeded values from a result. Accepts a boolean, a tagged `only`/`except` tuple or a config map with `values`/`fields` keys.

```elixir
toon do
  # Remove all fields with nil value
  compact true

  # Remove fields with nil value except for specified exceptions
  compact {:except, [:keep_nil]}

  # Remove fields with specific unwanted values
  compact %{values: [nil, false, ""]}
end
```

#### `merge`

A step to merge values into a result. Accepts a map or a tuples list.

Map has no guarantees about keys order so if you care about that prefer the list form.

```elixir
toon do
  # Merge with map
  merge %{key: "value"}

  # Merge with list
  merge key: "value"
end
```

#### `rename`

A step to rename keys in a result. Accepts a map, a tuples list or a function for mapping.

```elixir
toon do
  # Rename with map
  rename %{from_key: "to_key"}

  # Rename with list
  rename from_key: "to_key"

  # Rename with a function
  rename fn name -> String.capitalize(to_string(name)) end
end
```

#### `order`

A step to reorder keys in a result. Accepts a boolean, a sort function or a list of keys in a desired order.

If it is a list then it also acts as a filter and removes keys not present in that list.

```elixir
toon do
  # Order with standard `Enum.sort`
  order true

  # Order with a custom sort function
  order fn keys -> Enum.sort(keys, :desc) end

  # Order in accordance with a list
  order [:only, :these, :keys, :in, :that, "order"]
end
```

#### `customize`

A step to arbitrary customize a result. Accepts a function that will get a result and a resource record as arguments and return a modified result.

As mentioned above a result has a form of a list with two elements, key and value, tuples. To work with it you might want to use `List` methods like `List.keytake` or `List.keystore`.

```elixir
toon do
  customize fn result, _record ->
    result |> List.keystore(:custom_key, 0, {:custom_key, "custom_value"})
  end
end
```

### Typed structs

To use with `Ash.TypedStruct` add `AshToonEx.TypedStruct` extension.

All `toon` options and steps are the same except there are no `private?` or `sensitive?` filters in `pick` map form (since typed struct fields do not have those options).

```elixir
defmodule Example.TypedStruct do
  use Ash.TypedStruct,
    extensions: [AshToonEx.TypedStruct]
end
```

### Protocol

Each resource or typed struct with `AshToonEx` extension also implements `AshToonEx.Protocol`.

It provides a single method `get_fields` that retrieves a list of key/value field tuples following the same `AshToonEx`'s logic.

```elixir
AshToonEx.Protocol.get_fields(%MyResource{id: 1, name: "Alice"})
# => [id: 1, name: "Alice"]
```

### Encoding

With the extension applied, resources can be encoded directly to TOON format:

```elixir
user = %MyResource{id: 1, name: "Alice", email: "alice@example.com"}
ToonEx.encode!(user)
# => "email: alice@example.com\nid: 1\nname: Alice"
```

## Links

- [ToonEx](https://github.com/ohhi-vn/toon_ex) — TOON encoder/decoder for Elixir
- [ash_jason](https://github.com/vonagam/ash_jason) — Ash extension for Jason protocol (inspiration for this project)
- [Ash](https://github.com/ash-project/ash) — Resource framework for Elixir

## License

MIT License
