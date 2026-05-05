# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshToonEx.Resource.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer

  @impl true
    def transform(dsl) do
      AshToonEx.TransformerHelpers.transform(dsl, fn dsl, options ->
        # Get regular fields
        fields = Ash.Resource.Info.fields(dsl)
        fields = if Map.get(options, :private?), do: fields, else: Enum.filter(fields, & &1.public?)
        fields = if Map.get(options, :sensitive?), do: fields, else: Enum.reject(fields, &Map.get(&1, :sensitive?))

        # Add calculations if enabled
        fields =
          if Map.get(options, :calculations?, true) do
            calculations = Ash.Resource.Info.calculations(dsl)
            fields ++ calculations
          else
            fields
          end

        # Add aggregates if enabled
        fields =
          if Map.get(options, :aggregates?, true) do
            aggregates = Ash.Resource.Info.aggregates(dsl)
            fields ++ aggregates
          else
            fields
          end

        # Add relationships if enabled (only names, they'll be handled specially)
        fields =
          if Map.get(options, :relationships?, false) do
            relationships = Ash.Resource.Info.relationships(dsl)
            fields ++ relationships
          else
            fields
          end

        fields
      end)
    end
end
