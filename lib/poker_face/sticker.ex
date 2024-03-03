defmodule PokerFace.Sticker do
  def generate_sticker(photo) do
    model = Replicate.Models.get!("fofr/face-to-sticker")
    version = Replicate.Models.get_latest_version!(model)

    {:ok, prediction} =
      Replicate.Predictions.create(
        version,
        %{
          image: photo,
          # prompt: "a person",
          # negative_prompt: "",
          width: 1024,
          height: 1024,
          steps: 20,
          prompt_strength: 4.5,
          instant_id_strength: 0.7,
          ip_adapter_weight: 0.2,
          ip_adapter_noise: 0.5,
          upscale: false,
          upscale_steps: 10
        }
      )

    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    image_urls =
      prediction.output

    {:ok, {:images, image_urls}}
  end
end
