defmodule WTP.Impl.EventHandler do
  require Logger
  alias Nostrum.Struct.ApplicationCommandInteractionData, as: SlashCommandInteraction
  alias WTP.Impl.SlashCommands

  @spec handle(Nostrum.Consumer.ready()) :: :ok
  def handle({:READY, %{guilds: guilds}, _wsstate}) do
    guilds |> Enum.map(fn guild -> guild.id end) |> SlashCommands.Creator.start()
  end

  @spec handle(Nostrum.Consumer.interaction_create()) :: :ok
  def handle({:INTERACTION_CREATE, %{data: %SlashCommandInteraction{}} = interaction, _wsstate}) do
    SlashCommands.Handlers.Select.handle(interaction)
  end

  def handle({type, _message, _wsstate}) do
    Logger.debug("Event handler for #{Atom.to_string(type)} not implemented")
  end
end
