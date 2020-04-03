# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Event do
  @moduledoc false

  @derive {Jason.Encoder, except: [:type]}
  defstruct [:source, :data, :timestamp, type: :log]

  @type t :: %__MODULE__{}

  def to_event(log) do
    [
      "event: log\n",
      "data: ", Jason.encode_to_iodata!(log), "\n\n"
    ]
  end
end
