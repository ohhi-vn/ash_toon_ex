# SPDX-FileCopyrightText: 2024 ash_toon_ex contributors <https://github.com/manhvu/ash_toon_ex/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshToonEx.Phoenix.ToonSerializer do
  @moduledoc """
  Phoenix serializer for TOON format.

  This module provides helper functions to use TOON format in Phoenix controllers.

  ## Usage

  In your Phoenix controller:

      def show(conn, %{"id" => id}) do
        resource = MyResource |> Ash.get!(id)
        conn
        |> put_resp_content_type("application/x-toon")
        |> send_resp(200, ToonEx.encode!(resource))
      end

  You can also use it with `render/3` by encoding manually.
  """

  @doc """
  Encodes data to TOON format string.

  ## Examples

      iex> AshToonEx.Phoenix.ToonSerializer.encode(%{name: "Alice", age: 30})
      "age: 30\\nname: Alice"
  """
  def encode(data, _opts \\ []) do
    ToonEx.encode!(data)
  end

  @doc """
  Decodes TOON format string to Elixir data.

  ## Examples

      iex> AshToonEx.Phoenix.ToonSerializer.decode("name: Alice\\nage: 30")
      %{"name" => "Alice", "age" => 30}
  """
  def decode(toon_string, _opts \\ []) do
    case ToonEx.Decode.decode(toon_string) do
      {:ok, data} -> data
      {:error, error} -> raise "Failed to decode TOON string: #{inspect(error)}"
    end
  end

  if Code.ensure_loaded?(Plug.Conn) do
    @doc """
    Sends a TOON response.

    Requires Plug to be available.

    ## Examples

        def show(conn, %{"id" => id}) do
          resource = MyResource |> Ash.get!(id)
          AshToonEx.Phoenix.ToonSerializer.send_toon(conn, resource)
        end
    """
    def send_toon(conn, data, status \\ 200) do
      conn
      |> Plug.Conn.put_resp_content_type("application/x-toon")
      |> Plug.Conn.send_resp(status, encode(data))
    end
  end
end
