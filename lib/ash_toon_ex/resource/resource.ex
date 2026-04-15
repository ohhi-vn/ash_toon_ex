# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshToonEx.Resource do
  @moduledoc """
  `Ash.Resource` extension for implementing `ToonEx.Encoder` protocol.
  """

  use Spark.Dsl.Extension,
    sections: [AshToonEx.ExtensionHelpers.toon_section(Ash.Resource)],
    transformers: [AshToonEx.Resource.Transformer]
end
