defmodule PokerFace.Gemini do
  @vision_uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent"

  def analyze_image("data:image/png;base64," <> image_data) do
    prompt = """
      What's is he/she/it doing?
    """

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

    text =
      resp.body["candidates"]
      |> List.first()
      |> Map.get("content")
      |> Map.get("parts")
      |> List.first()
      |> Map.get("text")

    {:ok, text}
  end
end
