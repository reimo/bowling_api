defmodule GameWeb.FrameView do
  use GameWeb, :view

  def render("frame.json", %{frame: frame}) do
    %{
      id: frame.id,
      roll1: frame.roll1,
      roll2: frame.roll2,
      fill1: frame.fill1,
      fill2: frame.fill2,
      score: frame.score,
      kind: frame.kind,
      state: frame.state
    }
  end
end
