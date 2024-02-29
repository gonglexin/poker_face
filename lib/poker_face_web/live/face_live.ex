defmodule PokerFaceWeb.FaceLive do
  use PokerFaceWeb, :live_view

  alias PokerFace.Gemini

  @impl true
  def mount(_prams, _session, socket) do
    {:ok, assign(socket, :photo_info, nil)}
  end

  @impl true
  def handle_event("new_photo", %{"photo" => photo}, socket) do
    send(self(), {:anaylse, photo})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:anaylse, photo}, socket) do
    {:ok, text} = Gemini.analyze_image(photo)

    socket =
      socket
      |> assign(:photo_info, text)

    {:noreply, socket}
  end
end
