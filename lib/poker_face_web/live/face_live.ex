defmodule PokerFaceWeb.FaceLive do
  use PokerFaceWeb, :live_view

  alias PokerFace.{Gemini, Openai}

  @impl true
  def mount(_prams, _session, socket) do
    socket =
      socket
      |> assign(:photo_info, nil)
      |> assign(:form, to_form(%{"question" => nil}))

    {:ok, socket}
  end

  @impl true
  def handle_event("new_photo", %{"photo" => photo}, socket) do
    Task.async(fn ->
      Gemini.analyze_image(photo)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("ask", %{"question" => question, "photo" => photo}, socket) do
    Task.async(fn ->
      # Gemini.analyze_image(photo, question)
      Openai.analyze_image(photo, question)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, {:ok, text}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> assign(:photo_info, text)

    {:noreply, socket}
  end

  def handle_info({ref, {:error, text}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> assign(:photo_info, text)

    {:noreply, socket}
  end
end
