defmodule WTP.Impl.EventHandler do
  require Logger
  alias Nostrum.Struct.ApplicationCommandInteractionData, as: SlashCommandInteraction
  alias WTP.Impl.SlashCommands

  @spec handle(Nostrum.Consumer.guild_available()) :: :ok
  def handle({:GUILD_AVAILABLE, %{id: guild_id}, _wsstate}) do
    SlashCommands.Creator.create([guild_id])
  end

  @spec handle(Nostrum.Consumer.guild_create()) :: :ok
  def handle({:GUILD_CREATE, %{id: guild_id}, _wsstate}) do
    SlashCommands.Creator.create([guild_id])
  end

  @spec handle(Nostrum.Consumer.interaction_create()) :: :ok
  def handle({:INTERACTION_CREATE, %{data: %SlashCommandInteraction{}} = interaction, _wsstate}) do
    SlashCommands.Handlers.Select.handle(interaction)
  end

  def handle({type, _message, _wsstate}) do
    Logger.debug("Event handler for #{Atom.to_string(type)} not implemented")
  end
end
