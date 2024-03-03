defmodule PokerFace.Openai do
  require Logger

  @chat_completions_url "https://openrouter.ai/api/v1/chat/completions"

  def analyze_image("data:image/png;base64," <> _ = image_data, prompt \\ "What’s in this image?") do
    request = %{
      model: "gpt-4-vision-preview",
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

    resp = chat_completion(request)
    Logger.info(inspect(resp))

    resp.body
    |> parse_chat()
  end

  def chat_completion(request) do
    Req.post!(@chat_completions_url,
      json: request,
      auth: {:bearer, api_key()},
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
