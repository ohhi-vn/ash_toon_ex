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
               "id: #{@id}\ni: 1\nk: 1\nx: 1\nz: 1"
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
               "\"@type\": survey\nid: #{@id}\nk: 2\n\"✅\": 1\n❌: 10"
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
end
