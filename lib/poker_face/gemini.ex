defmodule PokerFace.Gemini do
  require Logger

  @vision_uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent"

  def analyze_image("data:image/png;base64," <> image_data, prompt \\ "What’s in this image?") do
    body = %{
      contents: [
        %{
          parts: [
            %{text: prompt},
            %{inlineData: %{mimeType: "image/png", data: image_data}}
          ]
        }
      ]
    }

    resp =
      Req.post!(@vision_uri <> "?key=#{System.get_env("GOOGLE_AI_API_KEY")}",
        json: body,
        receive_timeout: 60_000,
        connect_options: [protocols: [:http1]]
      )

    Logger.info(inspect(resp))

    case resp do
      %{status: 200} ->
        text =
          resp.body["candidates"]
          |> List.first()
          |> Map.get("content")
          |> Map.get("parts")
          |> List.first()
          |> Map.get("text")

        {:ok, text}

      _ ->
        {:error, resp.body["error"]["message"]}
    end
  end
end
