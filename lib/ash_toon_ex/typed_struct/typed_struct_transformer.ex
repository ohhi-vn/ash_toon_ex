# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshToonEx.TypedStruct.Transformer do
  @moduledoc false

  use Spark.Dsl.Transformer

  @impl true
  def transform(dsl) do
    AshToonEx.TransformerHelpers.transform(dsl, fn dsl, _options ->
      fields = Ash.TypedStruct.Info.fields(dsl)
      fields
    end)
  end
end
