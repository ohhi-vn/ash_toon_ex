# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshToonEx.TypedStruct do
  @moduledoc """
  `Ash.TypedStruct` extension for implementing `ToonEx.Encoder` protocol.
  """

  use Spark.Dsl.Extension,
    sections: [AshToonEx.ExtensionHelpers.toon_section(Ash.TypedStruct)],
    transformers: [AshToonEx.TypedStruct.Transformer]
end
