defmodule AshToonEx do
  @moduledoc """
  Ash extension for implementing `ToonEx.Encoder` protocol.

  ## Features

  - Encode Ash Resources and TypedStructs to TOON format
  - Configurable field picking with `pick` option
  - Compact output by removing unwanted values
  - Merge, rename, and reorder fields
  - Customize output with functions
  - Support for relationships, calculations, and aggregates (Ash Resources)
  - Phoenix integration helpers

  ## Usage

      defmodule MyApp.User do
        use Ash.Resource,
          extensions: [AshToonEx.Resource]

        toon do
          pick [:name, :email]
          compact true
          merge %{role: "user"}
        end
      end
  """

  @doc """
  Returns version information for the library.
  """
  def version do
    Mix.Project.config()[:version]
  end
end
