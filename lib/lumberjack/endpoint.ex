# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Router do
  use Plug.Router

  plug(Plug.RequestId)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/_logs" do
    Registry.register(Lumberjack.Registry, :logs, [])

    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    loop(conn)
  end

  defp loop(conn) do
    receive do
      {:log, msg} ->
        case chunk(conn, [Jason.encode_to_iodata!(msg), "\r\n"]) do
          {:ok, conn} -> loop(conn)
          {:error, :closed} -> conn
        end
    end
  end
end
