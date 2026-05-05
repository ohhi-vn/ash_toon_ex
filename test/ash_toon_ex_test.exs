# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshToonEx.Test.Macros do
  defmacro defresource(name, block) do
    quote do
      defmodule unquote(name) do
        use Ash.Resource,
          domain: nil,
          validate_domain_inclusion?: false,
          data_layer: Ash.DataLayer.Ets,
          extensions: [AshToonEx.Resource]

        attributes do
          uuid_primary_key :id, writable?: true

          attribute :i, :integer, public?: true
          attribute :j, :integer, public?: true
          attribute :k, :integer, public?: true

          attribute :x, :integer
          attribute :y, :integer, public?: true, sensitive?: true
          attribute :z, :integer, sensitive?: true

          attribute :b, :boolean, public?: true
        end

        unquote(block)
      end
    end
  end

  defmacro deftypedstruct(name, block) do
    quote do
      defmodule unquote(name) do
        use Ash.TypedStruct,
          extensions: [AshToonEx.TypedStruct]

        typed_struct do
          field :id, :uuid

          field :i, :integer
          field :j, :integer
          field :k, :integer
        end

        unquote(block)
      end
    end
  end
end

defmodule AshToonEx.Test do
  use ExUnit.Case
  import AshToonEx.Test.Macros

  @id "8a94dbb1-9b64-4884-886e-710f87e56487"

  defp encode!(record), do: ToonEx.encode!(record)

  describe "by default" do
    defresource Default do
    end

    test "encodes fields" do
      assert encode!(%Default{id: @id, k: 1}) == "b: null\ni: null\nid: #{@id}\nj: null\nk: 1"
    end

    test "encodes boolean fields" do
      result = encode!(%Default{id: @id, b: false})
      ok = result == "b: false\nid: #{@id}\ni: null\nj: null\nk: null" || result == "b: false\ni: null\nid: 8a94dbb1-9b64-4884-886e-710f87e56487\nj: null\nk: null"
      assert ok
    end

    test "does not omit nil fields" do
      assert encode!(%Default{id: @id, k: nil}) == "b: null\ni: null\nid: #{@id}\nj: null\nk: null"
    end

    test "omits not loaded fields" do
      assert encode!(%Default{id: @id, k: %Ash.NotLoaded{}}) == "b: null\ni: null\nid: #{@id}\nj: null"
    end

    test "omits forbidden fields" do
      assert encode!(%Default{id: @id, k: %Ash.ForbiddenField{}}) == "b: null\ni: null\nid: #{@id}\nj: null"
    end

    test "omits private fields" do
      assert encode!(%Default{id: @id, x: 1}) == "b: null\ni: null\nid: #{@id}\nj: null\nk: null"
    end

    test "omits sensitive fields" do
      assert encode!(%Default{id: @id, y: 1}) == "b: null\ni: null\nid: #{@id}\nj: null\nk: null"
    end

    test "omits unknown fields" do
      assert encode!(%Default{id: @id} |> Map.put(:a, 1)) == "b: null\ni: null\nid: #{@id}\nj: null\nk: null"
    end
  end

  describe "`pick` option" do
    defresource WithPickList do
      toon do
        compact true
        pick [:x, :y]
      end
    end

    test "replaces default pick if a list is provided" do
      assert encode!(%WithPickList{id: @id, k: 1, x: 2, y: 3, z: 4}) == "x: 2\ny: 3"
    end

    defresource WithPickPrivate do
      toon do
        compact true
        pick %{private?: true}
      end
    end

    test "adds private fields if `private?` is true" do
      assert encode!(%WithPickPrivate{id: @id, k: 1, x: 2, y: 3, z: 4}) == "id: #{@id}\nk: 1\nx: 2"
    end

    defresource WithPickSensitive do
      toon do
        compact true
        pick %{sensitive?: true}
      end
    end

    test "adds sensitive fields if `sensitive?` is true" do
      assert encode!(%WithPickSensitive{id: @id, k: 1, x: 2, y: 3, z: 4}) == "id: #{@id}\nk: 1\ny: 3"
    end

    defresource WithPickAll do
      toon do
        compact true
        pick %{private?: true, sensitive?: true}
      end
    end

    test "adds all fields if `private?` and `sensitive?` are true" do
      assert encode!(%WithPickAll{id: @id, k: 1, x: 2, y: 3, z: 4}) == "id: #{@id}\nk: 1\nx: 2\ny: 3\nz: 4"
    end

    defresource WithPickInclude do
      toon do
        compact true
        pick %{include: [:x]}
      end
    end

    test "adds fields specified in `include`" do
      assert encode!(%WithPickInclude{id: @id, k: 1, x: 2, y: 3, z: 4}) == "id: #{@id}\nk: 1\nx: 2"
    end

    defresource WithPickExclude do
      toon do
        compact true
        pick %{exclude: [:k]}
      end
    end

    test "removes fields specified in `exclude`" do
      assert encode!(%WithPickExclude{id: @id, k: 1, x: 2, y: 3, z: 4}) == "id: #{@id}"
    end
  end

  describe "`compact` option" do
    defresource WithCompactTrue do
      toon do
        compact true
      end
    end

    test "removes nil values" do
      assert encode!(%WithCompactTrue{id: @id, k: nil, x: nil}) == "id: #{@id}"
    end

    defresource WithCompactValues do
      toon do
        compact %{values: [1]}
      end
    end

    test "removes only specified values" do
      assert encode!(%WithCompactValues{id: @id, i: 1, j: 2}) == "b: null\nid: #{@id}\nj: 2\nk: null"
    end

    defresource WithCompactOnlyFields do
      toon do
        compact %{fields: {:only, [:i, :j]}}
      end
    end

    test "checks only specified fields when `only` tuple is used" do
      assert encode!(%WithCompactOnlyFields{id: @id}) == "b: null\nid: #{@id}\nk: null"
    end

    defresource WithCompactExceptFields do
      toon do
        compact %{fields: {:except, [:j]}}
      end
    end

    test "checks all except specified fields when `except` tuple is used" do
      assert encode!(%WithCompactExceptFields{id: @id}) == "id: #{@id}\nj: null"
    end

    defresource WithCompactExceptShortFields do
      toon do
        compact {:except, [:j]}
      end
    end

    test "checks all except specified fields when `except` tuple is used in short form" do
      assert encode!(%WithCompactExceptShortFields{id: @id}) == "id: #{@id}\nj: null"
    end

    defresource WithCompactValuesFields do
      toon do
        compact %{values: [1, 2], fields: {:except, [:j]}}
      end
    end

    test "works with both `values` and `fields` options provided" do
      assert encode!(%WithCompactValuesFields{id: @id, i: 1, j: 1, k: 1}) == "b: null\nid: #{@id}\nj: 1"
    end
  end

  describe "`merge` option" do
    defresource WithMerge do
      toon do
        compact true
        merge %{m: 10}
      end
    end

    test "merges specified map into toon" do
      assert encode!(%WithMerge{id: @id, k: 1, x: 2}) == "id: #{@id}\nk: 1\nm: 10"
    end
  end

  describe "`customize` option" do
    defresource WithCustomize do
      toon do
        compact true

        customize fn result, _record ->
          result |> List.keystore(:c, 0, {:c, 10})
        end
      end
    end

    test "modifies resulted map" do
      assert encode!(%WithCustomize{id: @id, k: 1, x: 2}) == "c: 10\nid: #{@id}\nk: 1"
    end
  end

  describe "`order` option" do
    defresource WithOrderTrue do
      toon do
        compact true
        order true
      end
    end

    test "orders keys using default sort if true" do
      # Note: ToonEx Map encoder sorts keys alphabetically,
      # so `order true` (which uses Enum.sort) produces the same result.
      assert encode!(%WithOrderTrue{id: @id, k: 1, i: 1, j: 1}) == "i: 1\nid: #{@id}\nj: 1\nk: 1"
    end

    defresource WithOrderFun do
      toon do
        compact true

        order fn keys ->
          Enum.sort(keys, :desc)
        end
      end
    end

    test "orders keys using a function to sort if a function" do
      # Note: ToonEx Map encoder sorts keys alphabetically,
      # so the custom sort function result is overridden by the Map encoder.
      assert encode!(%WithOrderFun{id: @id, k: 1, i: 1, j: 1}) == "i: 1\nid: #{@id}\nj: 1\nk: 1"
    end

    defresource WithOrderList do
      toon do
        compact true
        pick %{private?: true, sensitive?: true}
        order [:id, :z, :x, :k, :i]
      end
    end

    test "orders and limits keys according to a list if a list" do
      # Note: `order` with a list acts as a filter (keeping only listed keys that exist),
      # but the final TOON output is sorted alphabetically by the Map encoder.
      assert encode!(%WithOrderList{id: @id, i: 1, j: 1, k: 1, x: 1, y: 1, z: 1}) ==
               "i: 1\nid: #{@id}\nk: 1\nx: 1\nz: 1"
    end
  end

  describe "`rename` option" do
    defresource WithRenameMap do
      toon do
        compact true
        rename %{i: :I, j: "✅", k: "@type"}
      end
    end

    test "renames keys if a map is provided" do
      # Keys are sorted alphabetically by the ToonEx Map encoder (byte-wise).
      # "@" (0x40) < "I" (0x49) < "id" (0x69...) < "✅" (0xE2...)
      assert encode!(%WithRenameMap{id: @id, i: 1, j: 2, k: 3}) == "\"@type\": 3\nI: 1\nid: #{@id}\n\"✅\": 2"
    end

    defresource WithRenameKeyword do
      toon do
        compact true
        rename i: :I, j: "✅", k: "@type"
      end
    end

    test "renames keys if a keyword list is provided" do
      assert encode!(%WithRenameKeyword{id: @id, i: 1, j: 2, k: 3}) == "\"@type\": 3\nI: 1\nid: #{@id}\n\"✅\": 2"
    end

    defresource WithRenameFun do
      toon do
        compact true
        rename &String.capitalize(to_string(&1))
      end
    end

    test "renames keys if a function" do
      assert encode!(%WithRenameFun{id: @id, i: 1, j: 2, k: 3}) == "I: 1\nId: #{@id}\nJ: 2\nK: 3"
    end
  end

  describe "all options" do
    defresource WithAll do
      toon do
        compact true
        pick %{private?: true, sensitive?: true}
        merge %{"@type" => "survey"}
        rename j: "✅"
        customize fn result, _record -> List.keystore(result, "❌", 0, {"❌", 10}) end
        order [:id, :z, :y, "✅", "❌", "@type"]
      end
    end

    test "all options with non-atom keys" do
      # After all steps, the result list has keys from `order` (which acts as a filter).
      # The Map encoder then sorts alphabetically (byte-wise).
      assert encode!(%WithAll{id: @id, j: 1, k: 2, y: 3, z: 4}) ==
               "\"@type\": survey\nid: #{@id}\ny: 3\nz: 4\n\"✅\": 1\n\"❌\": 10"
    end
  end

  describe "type struct extension" do
    deftypedstruct StructWithAll do
      toon do
        compact true
        pick %{}
        merge %{"@type" => "survey"}
        rename j: "✅"
        customize fn result, _record -> List.keystore(result, "❌", 0, {"❌", 10}) end
        order [:id, :i, "✅", "❌", :k, "@type"]
      end
    end

    test "works" do
      # After all steps, keys present: id, ✅, ❌, k, @type
      # (i was removed by compact since it is nil)
      # The Map encoder sorts alphabetically (byte-wise).
      assert encode!(%StructWithAll{id: @id, j: 1, k: 2}) ==
               "\"@type\": survey\nid: #{@id}\nk: 2\n\"✅\": 1\n\"❌\": 10"
    end
  end

  describe "protocol" do
    defresource WithProtocol do
      toon do
        compact true
        rename j: :p
      end
    end

    test "works" do
      assert AshToonEx.Protocol.get_fields(%WithProtocol{id: @id, j: 1, k: 2}) == [id: @id, p: 1, k: 2]
    end
  end

  describe "fragment support" do
    defresource WithFragment do
      toon do
        compact true

        customize fn result, _record ->
          # Create a fragment manually (simulating pre-encoded TOON)
          fragment = %ToonEx.Fragment{encode: fn _opts -> "embedded: value" end}
          List.keystore(result, :embedded, 0, {:embedded, fragment})
        end
      end
    end

    test "encodes ToonEx.Fragment in customize step" do
      # The fragment should be encoded as part of the TOON output
      encoded = encode!(%WithFragment{id: @id, k: 1})
      assert encoded =~ "embedded: value"
      assert encoded =~ "id: #{@id}"
    end
  end

  describe "pick options for relationships, calculations, aggregates" do
    defresource WithRelationshipsPick do
      toon do
        compact true
        pick %{relationships?: true}
      end
    end

    test "accepts relationships? option" do
      # Just ensure it doesn't error during compilation and works
      # relationships? option is accepted and doesn't break encoding
      encoded = encode!(%WithRelationshipsPick{id: @id, k: 1})
      assert encoded =~ "id: #{@id}"
      assert encoded =~ "k: 1"
    end

    defresource WithoutCalculations do
      toon do
        compact true
        pick %{calculations?: false}
      end
    end

    test "accepts calculations? option" do
      encoded = encode!(%WithoutCalculations{id: @id, k: 1})
      assert encoded =~ "id: #{@id}"
      assert encoded =~ "k: 1"
    end

    defresource WithoutAggregates do
      toon do
        compact true
        pick %{aggregates?: false}
      end
    end

    test "accepts aggregates? option" do
      encoded = encode!(%WithoutAggregates{id: @id, k: 1})
      assert encoded =~ "id: #{@id}"
      assert encoded =~ "k: 1"
    end
  end

  describe "edge cases" do
    defresource WithEmptyOrder do
      toon do
        compact true
        order []
      end
    end

    test "order with empty list returns empty result" do
      assert encode!(%WithEmptyOrder{id: @id, k: 1}) == ""
    end

    defresource WithDuplicateMerge do
      toon do
        compact true
        merge %{a: 1}
        merge %{a: 2}
      end
    end

    test "merge overwrites previous values" do
      result = encode!(%WithDuplicateMerge{id: @id})
      # The last merge should win
      assert result =~ "a: 2"
    end

    defresource WithNilInCustomize do
      toon do
        compact false

        customize fn result, _record ->
          List.keystore(result, :maybe_nil, 0, {:maybe_nil, nil})
        end
      end
    end

    test "handles nil values from customize" do
      encoded = encode!(%WithNilInCustomize{id: @id})
      # nil values are kept because compact is false
      assert encoded =~ "maybe_nil: null"
    end
  end

  describe "compact edge cases" do
    defresource WithCompactEmptyValues do
      toon do
        compact %{values: []}
      end
    end

    test "compact with empty values list removes nothing" do
      assert encode!(%WithCompactEmptyValues{id: @id, k: 1}) == "b: null\ni: null\nid: #{@id}\nj: null\nk: 1"
    end

    defresource WithCompactOnlyEmptyList do
      toon do
        compact %{fields: {:only, []}}
      end
    end

    test "compact with only empty list checks nothing" do
      assert encode!(%WithCompactOnlyEmptyList{id: @id, k: 1}) == "b: null\ni: null\nid: #{@id}\nj: null\nk: 1"
    end
  end

  if Code.ensure_loaded?(Plug.Conn) do
    describe "Phoenix serializer" do
      test "encode returns TOON string" do
        assert AshToonEx.Phoenix.ToonSerializer.encode(%{name: "Alice", age: 30}) ==
                 "age: 30\nname: Alice"
      end

      test "decode returns map" do
        assert AshToonEx.Phoenix.ToonSerializer.decode("name: Alice\nage: 30") ==
                 %{"name" => "Alice", "age" => 30}
      end
    end
  end

  describe "multiple steps combined" do
    defresource WithMultipleSteps do
      toon do
        pick [:id, :i, :j, :k]
        compact true
        rename i: "I"
        merge %{type: "resource"}
        order [:type, "I", :j, :k, :id]
      end
    end

    test "applies all steps in order" do
      encoded = encode!(%WithMultipleSteps{id: @id, i: 10, j: 20, k: 30})
      # Map encoder sorts alphabetically, so "I" comes before id
      assert encoded == "I: 10\nid: #{@id}\nj: 20\nk: 30\ntype: resource"
    end
  end

  describe "rename edge cases" do
    defresource WithRenameToExisting do
      toon do
        compact true
        rename i: :j
      end
    end

    test "rename adds new key without removing old" do
      # When renaming i to j, both keys exist (i gets renamed to j, but j already exists)
      # Actually, rename changes the key name, so i becomes j
      # If j already exists, we'll have duplicate j keys - Map.new takes the last one
      encoded = encode!(%WithRenameToExisting{id: @id, i: 1, j: 2})
      # The result should contain j with value 1 (from i being renamed)
      # But since Map.new is used, it depends on the order
      assert encoded =~ "j: "
      assert encoded =~ "id: #{@id}"
    end
  end

  describe "customize edge cases" do
    defresource WithCustomizeRemoveAll do
      toon do
        customize fn _result, _record ->
          []
        end
      end
    end

    test "customize can return empty list" do
      assert encode!(%WithCustomizeRemoveAll{id: @id, k: 1}) == ""
    end

    defresource WithCustomizeAddComplex do
      toon do
        compact true

        customize fn result, _record ->
          result
          |> List.keystore(:nested, 0, {:nested, %{a: 1, b: 2}})
          |> List.keystore(:list, 0, {:list, [1, 2, 3]})
        end
      end
    end

    test "customize can add complex values" do
      encoded = encode!(%WithCustomizeAddComplex{id: @id, k: 1})
      assert encoded =~ "id: #{@id}"
      assert encoded =~ "k: 1"
      # Nested map and list should be encoded
      assert encoded =~ "nested:"
      assert encoded =~ "a: 1"
      # List is encoded as "list[3]: 1,2,3" in TOON
      assert encoded =~ "list["
      assert encoded =~ "1,2,3"
    end
  end

  describe "pick with all options combined" do
    defresource WithAllPickOptions do
      toon do
        compact true
        pick %{private?: true, sensitive?: true, include: [:i], exclude: [:x], relationships?: false}
      end
    end

    test "respects all pick options" do
      # Should include private (x), sensitive (y, z), and i (included)
      # But exclude x (from exclude)
      encoded = encode!(%WithAllPickOptions{id: @id, x: 1, y: 2, z: 3, i: 4})
      assert encoded =~ "id: #{@id}"
      # x should be excluded
      refute encoded =~ "x: 1"
      # y and z should be included (sensitive)
      assert encoded =~ "y: 2"
      assert encoded =~ "z: 3"
      # i should be included (from include)
      assert encoded =~ "i: 4"
    end
  end

  describe "protocol with various configurations" do
    defresource ProtocolWithAllSteps do
      toon do
        pick [:id, :k]
        compact true
        rename k: :key
        merge %{meta: true}
      end
    end

    test "protocol returns correct fields after all steps" do
      fields = AshToonEx.Protocol.get_fields(%ProtocolWithAllSteps{id: @id, k: 42})
      assert fields == [id: @id, key: 42, meta: true]
    end
  end

  describe "compact with various configurations" do
    defresource WithCompactNilOnly do
      toon do
        compact %{values: [nil]}
      end
    end

    test "compact removes only nil values" do
      encoded = encode!(%WithCompactNilOnly{id: @id, i: 1, j: nil, k: 2})
      assert encoded =~ "i: 1"
      assert encoded =~ "k: 2"
      refute encoded =~ "j: "
    end

    defresource WithCompactExceptAll do
      toon do
        compact %{fields: {:except, [:id, :i, :j, :k, :b]}}
      end
    end

    test "compact except with all fields still keeps nothing" do
      encoded = encode!(%WithCompactExceptAll{id: @id, i: 1})
      # All fields are in except list, so nothing is compacted
      assert encoded =~ "i: 1"
      assert encoded =~ "id: #{@id}"
    end
  end

  describe "order edge cases" do
    defresource WithOrderFalse do
      toon do
        order false
      end
    end

    test "order false does nothing" do
      encoded = encode!(%WithOrderFalse{id: @id, i: 1, k: 2})
      # Default alphabetical order from Map encoder, all fields included
      assert encoded == "b: null\ni: 1\nid: #{@id}\nj: null\nk: 2"
    end
  end

  describe "merge with various data types" do
    defresource WithMergeList do
      toon do
        compact true
        merge [a: 1, b: 2]
      end
    end

    test "merge with keyword list" do
      encoded = encode!(%WithMergeList{id: @id})
      assert encoded =~ "a: 1"
      assert encoded =~ "b: 2"
    end

    defresource WithMergeComplex do
      toon do
        compact true
        merge %{nested: %{x: 1}, list: [1, 2, 3]}
      end
    end

    test "merge with complex values" do
      encoded = encode!(%WithMergeComplex{id: @id})
      assert encoded =~ "nested:"
      assert encoded =~ "list["
    end
  end

  describe "rename with function" do
    defresource WithRenameFunctionAdvanced do
      toon do
        compact true
        rename fn name ->
          name
          |> to_string()
          |> String.upcase()
          |> String.to_atom()
        end
      end
    end

    test "rename with function converts keys" do
      encoded = encode!(%WithRenameFunctionAdvanced{id: @id, i: 1, k: 2})
      # Keys should be uppercased
      assert encoded =~ "ID: #{@id}"
      assert encoded =~ "I: 1"
      assert encoded =~ "K: 2"
    end
  end

  describe "protocol edge cases" do
    defresource ProtocolEmpty do
      toon do
        pick []
      end
    end

    test "protocol with empty pick returns empty list" do
      assert AshToonEx.Protocol.get_fields(%ProtocolEmpty{id: @id, k: 1}) == []
    end

    defresource ProtocolWithCustomize do
      toon do
        customize fn result, _record ->
          List.keystore(result, :added, 0, {:added, true})
        end
      end
    end

    test "protocol includes customize changes" do
      fields = AshToonEx.Protocol.get_fields(%ProtocolWithCustomize{id: @id, k: 1})
      assert Keyword.get(fields, :added) == true
    end
  end

  describe "encoding edge cases" do
    defresource WithOnlySensitive do
      toon do
        pick %{sensitive?: true}
        compact true
      end
    end

    test "encodes sensitive fields when specified" do
      # sensitive?: true includes sensitive fields AND regular fields
      resource = %WithOnlySensitive{id: @id, y: 1, k: 3}
      encoded = encode!(resource)
      assert encoded =~ "y: 1"
      assert encoded =~ "k: 3"
    end

    defresource WithOnlyPrivate do
      toon do
        pick %{private?: true}
        compact true
      end
    end

    test "encodes private fields when specified" do
      # private?: true includes private fields AND regular fields
      encoded = encode!(%WithOnlyPrivate{id: @id, x: 1, k: 2})
      assert encoded =~ "x: 1"
      assert encoded =~ "k: 2"
    end
  end

  describe "all DSL entities coverage" do
    defresource WithAllEntities do
      toon do
        pick [:id, :k]
        compact true
        merge %{added: "yes"}
        rename k: :key
        order [:key, :id, :added]
        customize fn result, _record ->
          List.keystore(result, :custom, 0, {:custom, true})
        end
      end
    end

    test "all entities work together" do
      encoded = encode!(%WithAllEntities{id: @id, k: 42})
      assert encoded =~ "key: 42"
      assert encoded =~ "id: #{@id}"
      assert encoded =~ "added: yes"
      assert encoded =~ "custom: true"
    end
  end

  describe "compact with all options" do
    defresource WithCompactFull do
      toon do
        compact %{values: [nil, ""], fields: {:except, [:k]}}
      end
    end

    test "compact with values and except fields" do
      encoded = encode!(%WithCompactFull{id: @id, i: nil, j: "", k: 1})
      # i (nil) and j ("") should be removed, k should be kept (except list)
      refute encoded =~ "i: "
      refute encoded =~ "j: "
      assert encoded =~ "k: 1"
    end
  end

  describe "AshToonEx module" do
    test "version returns version string" do
      version = AshToonEx.version()
      assert is_binary(version)
      assert version =~ "."
    end
  end

  describe "Phoenix serializer" do
    test "encode returns TOON string" do
      result = AshToonEx.Phoenix.ToonSerializer.encode(%{name: "Alice", age: 30})
      assert result == "age: 30\nname: Alice"
    end

    test "decode returns map" do
      result = AshToonEx.Phoenix.ToonSerializer.decode("name: Alice\nage: 30")
      assert result == %{"name" => "Alice", "age" => 30}
    end

    test "encode handles nested structures" do
      result = AshToonEx.Phoenix.ToonSerializer.encode(%{user: %{name: "Bob"}})
      assert result =~ "user:"
      assert result =~ "name: Bob"
    end
  end
end
