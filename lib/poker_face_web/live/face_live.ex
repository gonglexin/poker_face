defmodule PokerFaceWeb.FaceLive do
  use PokerFaceWeb, :live_view

  alias PokerFace.{Openai, Sticker}

  @impl true
  def mount(_prams, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{"question" => nil}))

    {:ok, socket}
  end

  @impl true
  def handle_event("new_photo", %{"photo" => photo}, socket) do
    Task.async(fn ->
      Sticker.generate_sticker(photo)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("ask", %{"question" => question, "photo" => photo}, socket) do
    Task.async(fn ->
      Openai.analyze_image(photo, question)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, {:ok, {:images, images}}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> push_event(:ai_message, %{type: "image", text: images |> List.last()})

    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, {:ok, text}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> push_event(:ai_message, %{type: "text", text: text})

    {:noreply, socket}
  end

  def handle_info({ref, {:error, text}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> push_event(:ai_message, %{type: "text", text: text})

    {:noreply, socket}
  end
end
