defmodule WTP.Runtime.Application do
  @super_name WTPStarter

  use Application

  def start(_type, _args) do
    children = [WTP.Runtime.Server]
    Supervisor.start_link(children, strategy: :one_for_one, name: @super_name)
  end
end
