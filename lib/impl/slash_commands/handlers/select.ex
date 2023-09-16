defmodule WTP.Impl.SlashCommands.Handlers.Select do
  require Logger
  alias Nostrum.Api, as: NostrumApi
  alias Nostrum.Struct.ApplicationCommandInteractionData, as: SlashCommandInteraction

  def handle(interaction) do
    interaction
    |> process_command()
  end

  defp process_command(
         %{
           data: %SlashCommandInteraction{
             options: [
               %{name: "list", value: opts_string_list} | other_options
             ]
           }
         } =
           interaction
       ) do
    separator = get_separator_from_options(other_options)

    opts_string_list
    |> String.split(separator, trim: true)
    |> pick_random_option()
    |> send_response(interaction)
  end

  defp process_command(value),
    do: Logger.error("Error Processing Select Command, received: #{inspect(value)}")

  defp pick_random_option(opt_list) do
    Enum.random(opt_list)
  end

  defp get_separator_from_options(options) do
    default_separator = %{value: " "}

    options
    |> Enum.find(default_separator, fn option -> option.name === "separator" end)
    |> Map.get(:value)
    |> format_separator()
  end

  # Seems that either Discord API or Nostrum sanitized input, so this does not take effect. Left in case
  defp format_separator(" " = separator), do: separator
  defp format_separator(separator), do: String.trim(separator)

  defp send_response(picked_option, interaction) do
    # Give some time
    Process.sleep(1000)

    response = %{
      type: Nostrum.Constants.InteractionCallbackType.channel_message_with_source(),
      data: %{
        content: picked_option
      }
    }

    case NostrumApi.create_interaction_response(interaction, response) do
      {:ok} ->
        :ok

      error ->
        Logger.error("Error sending interaction back #{inspect(error, pretty: true)}")
        :error
    end
  end
end
