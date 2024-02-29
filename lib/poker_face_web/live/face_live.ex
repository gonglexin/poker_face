defmodule PokerFaceWeb.FaceLive do
  use PokerFaceWeb, :live_view

  alias PokerFace.Gemini

  @impl true
  def mount(_prams, _session, socket) do
    {:ok, assign(socket, :photo_info, nil)}
  end

  @impl true
  def handle_event("new_photo", %{"photo" => photo}, socket) do
    Task.async(fn ->
      Gemini.analyze_image(photo)
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
