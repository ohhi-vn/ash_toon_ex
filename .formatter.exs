# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

# Used by "mix format"
spark_locals_without_parens = [
  pick: 1,
  compact: 1,
  merge: 1,
  rename: 1,
  order: 1,
  customize: 1
]

[
  import_deps: [:ash, :spark],
  plugins: [Spark.Formatter, FreedomFormatter],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 120,
  trailing_comma: true,
  local_pipe_with_parens: true,
  single_clause_on_do: true,
  locals_without_parens: spark_locals_without_parens,
  export: [locals_without_parens: spark_locals_without_parens]
]
