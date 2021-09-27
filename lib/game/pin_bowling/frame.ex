defmodule Frame do
  defstruct [:roll1, :roll2, :fill1, :fill2, score: 0, kind: "open", state: "started"]
  @type roll :: 0..10
  @type kind :: String.t()
  @type state :: String.t()
  @type t :: %Frame{
          roll1: roll,
          roll2: roll,
          fill1: roll,
          fill2: roll,
          score: 0..30,
          kind: kind,
          state: state
        }
  @pins 10
  @doc """
    record the number of pins knocked down per roll
  """
  @spec roll(frame :: t, roll :: integer) :: {:ok, t} | {:error, String.t()}
  def roll(_frame, roll) when roll < 0 do
    {:error, "Negative roll is invalid"}
  end

  def roll(_frame, roll) when roll > @pins do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll(%Frame{roll1: nil} = frame, @pins) do
    {:ok, %{frame | roll1: @pins, score: @pins, kind: "strike"}}
  end

  def roll(%Frame{roll1: nil} = frame, roll) do
    {:ok, %{frame | roll1: roll, score: roll, kind: "open"}}
  end

  def roll(%Frame{state: "finished"} = frame, _roll) do
    {:ok, frame}
  end

  def roll(%Frame{kind: "strike", score: score, fill1: nil} = frame, roll) do
    {:ok, %{frame | fill1: roll, score: score + roll}}
  end

  def roll(%Frame{kind: "strike", fill1: fill1, fill2: nil}, roll)
      when fill1 < @pins and fill1 + roll > @pins do
    {:error, "Pin count exceeds pins on the lane"}
  end

  def roll(%Frame{kind: "strike", score: score, fill2: nil} = frame, roll) do
    {:ok, %{frame | fill2: roll, score: score + roll, state: "finished"}}
  end

  def roll(%Frame{kind: "spare", score: score, fill1: nil} = frame, roll) do
    {:ok, %{frame | fill1: roll, score: score + roll, state: "finished"}}
  end

  def roll(%Frame{kind: "open", score: score, roll2: nil} = frame, roll) do
    points = score + roll

    cond do
      points < @pins -> {:ok, %{frame | roll2: roll, score: points, state: "finished"}}
      points == @pins -> {:ok, %{frame | roll2: roll, score: points, kind: "spare"}}
      points > @pins -> {:error, "Pin count exceeds pins on the lane"}
    end
  end
end
