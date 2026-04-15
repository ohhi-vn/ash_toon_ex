defmodule AshToonEx do
  @moduledoc """
  Ash extension for implementing `ToonEx.Encoder` protocol.

  Usage:
  ```elixir
  defmodule MyApp.User do
    use Ash.Resource,
      extensions: [AshToonEx.Resource]

    # Optional configuration
    toon do
      pick [:name, :email]
      compact true
      merge %{role: "user"}
    end
  end
  ```
  """
end
