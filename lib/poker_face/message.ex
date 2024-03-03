defmodule PokerFace.Message do
  defstruct [:id, :user_type, :type, :text]

  def new(user_type, type, text) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      user_type: user_type,
      type: type,
      text: text
    }
  end

  def initial_messages() do
    [
      new(:ai, :text, "Hi, I'm PokerFace. How can I help you?"),
      new(:ai, :text, "Click the 'Generate Sticket' button to get a stick avatar."),
      new(:ai, :text, "Type any question you want to ask about the image in your camera."),
      new(:user, :text, "Here is a user input example message.")
    ]
  end
end
