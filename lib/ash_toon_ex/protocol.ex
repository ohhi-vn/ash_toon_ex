# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defprotocol AshToonEx.Protocol do
  @moduledoc """
  A protocol that provides a way to get fields from a record using `AshToonEx`'s logic.
  """

  @spec get_fields(t()) :: [{t(), t()}]
  def get_fields(struct)
end
