# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack do
  @moduledoc """
  Documentation for `Lumberjack`.
  """

  @html """
  <html>
    <head>
      <title>I am lumberjack, and I am ok!</title>
      <link rel="stylesheet" href="/assets/css/main.css" />
      <script src="/assets/js/main.js" defer async></script>
    </head>
    <body>
      <table>
        <thead>
          <tr>
            <th class="src ui">Source</th>
            <th class="tms ui">Time</th>
            <th class="lvl ui">Level</th>
            <th class="msg ui">Message</th>
          </tr>
        </thead>
        <tbody id="logs"></tbody>
      </table>
      <div class="navigation ui">
        <label for="autoscroll"><input type="checkbox" id="autoscroll" checked />&nbsp;Autoscroll</label>
        <label for="show_sources"><input type="checkbox" id="show_sources" />&nbsp;Show sources</label>
        <label for="light"><input type="checkbox" id="light" />&nbsp;Light theme</label>
      </div>
      <div id="modal" class="modal ui" hidden></div>
    </body>
  </html>
  """

  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, @html)
  end

  get "/stream" do
    conn =
      conn
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    Enum.reduce_while(Lumberjack.stream(), conn, fn msg, conn ->
      case chunk(conn, Lumberjack.Event.to_event(msg)) do
        {:ok, conn} -> {:cont, conn}
        {:error, :closed} -> {:halt, conn}
      end
    end)
  end

  defdelegate stream, to: Lumberjack.Source
end
