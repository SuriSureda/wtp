defmodule WTP.Impl.SlashCommands.Creator do
  require Logger
  alias Nostrum.Constants.ApplicationCommandOptionType
  alias Nostrum.Constants.ApplicationCommandType
  alias Nostrum.Struct.{ApplicationCommand, Guild}
  alias Nostrum.Api, as: NostrumApi

  @type guild_id :: Guild.id()
  @type command :: ApplicationCommand.application_command_map()

  def start(guild_ids) do
    if Application.get_env(:wtp, :environment) == :prod do
      create()
    else
      create(guild_ids)
    end
  end

  @spec create() :: :ok
  def create() do
    commands()
    |> create_commands()
  end

  @spec create([guild_id]) :: :ok
  def create(guild_ids) do
    guild_ids
    |> Enum.each(fn guild ->
      create_commands(commands(), guild)
    end)

    :ok
  end

  @spec create_commands([command]) :: :ok
  defp create_commands(commands) do
    commands
    |> Enum.map(fn command ->
      Task.async(fn ->
        create_command(command)
      end)
    end)
    |> Task.await_many(:infinity)

    :ok
  end

  @spec create_commands([command], guild_id) :: :ok
  defp create_commands(commands, guild_id) do
    commands
    |> Enum.map(fn command ->
      Task.async(fn ->
        create_command(command, guild_id)
      end)
    end)
    |> Task.await_many(:infinity)

    :ok
  end

  @spec create_command(command) :: :ok | :error
  defp create_command(command) do
    case NostrumApi.create_global_application_command(command) do
      {:ok, _map} ->
        Logger.info("Command #{command.name} created successfully.")
        :ok

      {:error, api_error} ->
        Logger.error(
          "Command #{command.name} creation failed [#{inspect(api_error, pretty: true)}]"
        )

        :error
    end
  end

  @spec create_command(command, guild_id) :: :ok | :error
  defp create_command(command, guild_id) do
    case NostrumApi.create_guild_application_command(guild_id, command) do
      {:ok, _map} ->
        Logger.info("#{guild_id}: Command #{command.name} created successfully.")
        :ok

      {:error, api_error} ->
        Logger.error(
          "#{guild_id}: Command #{command.name} creation failed [#{inspect(api_error, pretty: true)}]"
        )

        :error
    end
  end

  @spec commands() :: [command]
  defp commands() do
    [
      %{
        name: "select",
        description: "select a random input from the given list",
        type: ApplicationCommandType.chat_input(),
        options: [
          %{
            type: ApplicationCommandOptionType.string(),
            name: "list",
            description: "Game List (names separated by commas)",
            required: true
          }
        ]
      }
    ]
  end
end
