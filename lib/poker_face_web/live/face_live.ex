defmodule PokerFaceWeb.FaceLive do
  use PokerFaceWeb, :live_view

  alias PokerFace.{Openai, Sticker, Message}

  @impl true
  def mount(_prams, _session, socket) do
    socket =
      socket
      |> assign(:form, to_form(%{"question" => nil}))
      |> stream(:messages, Message.initial_messages())

    {:ok, socket}
  end

  @impl true
  def handle_event("new_photo", %{"photo" => photo}, socket) do
    Task.async(fn ->
      Sticker.generate_sticker(photo)
    end)

    socket =
      stream_insert(
        socket,
        :messages,
        Message.new(:user, :text, "Gererate Sticker")
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("ask", %{"question" => question, "photo" => photo}, socket) do
    Task.async(fn ->
      Openai.analyze_image(photo, question)
    end)

    socket =
      stream_insert(
        socket,
        :messages,
        Message.new(:user, :text, question)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, {:ok, {:images, images}}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      stream_insert(
        socket,
        :messages,
        Message.new(:ai, :image, images |> List.last())
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, {:ok, text}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      stream_insert(
        socket,
        :messages,
        Message.new(:ai, :text, text)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, {:error, text}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      stream_insert(
        socket,
        :messages,
        Message.new(:ai, :text, text)
      )

    {:noreply, socket}
  end
end
