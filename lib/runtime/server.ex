defmodule WTP.Runtime.Server do
  use Nostrum.Consumer

  alias WTP.Impl.EventHandler

  def handle_event(event) do
    EventHandler.handle(event)
  end
end
