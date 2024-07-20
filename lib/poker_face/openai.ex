defmodule PokerFace.Openai do
  require Logger

  @chat_completions_url "https://api.openai.com/v1/chat/completions"
  @openrouter_chat_completions_url "https://openrouter.ai/api/v1/chat/completions"

  def analyze_image(
        "data:image/png;base64," <> _ = image_data,
        prompt \\ "What’s in this image?",
        openai_api_key
      ) do
    request = %{
      model: "gpt-4o-mini",
      messages: [
        %{
          role: "user",
          content: [
            %{type: "text", text: prompt},
            %{type: "image_url", image_url: %{url: image_data}}
          ]
        }
      ]
    }

    resp = chat_completion(request, openai_api_key)
    Logger.info(inspect(resp))

    resp.body
    |> parse_chat()
  end

  def chat_completion(request, openai_api_key) do
    key =
      case openai_api_key do
        "" -> api_key()
        _ -> openai_api_key
      end

    url =
      case openai_api_key do
        "" -> @openrouter_chat_completions_url
        _ -> @chat_completions_url
      end

    Req.post!(url,
      json: request,
      auth: {:bearer, key},
      receive_timeout: 600_000,
      connect_options: [protocols: [:http1]]
    )
  end

  defp api_key() do
    System.get_env("OPENAI_API_KEY")
  end

  def parse_chat(%{"choices" => [%{"message" => %{"content" => content}} | _]}) do
    {:ok, content}
  end

  def parse_chat(error) do
    {:error, error["error"]["message"]}
  end
end
