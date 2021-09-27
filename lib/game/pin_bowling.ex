defmodule Game.PinBowling do
  @moduledoc """
  The PinBowling context.
  """

  import Ecto.Query, warn: false
  alias Game.Repo
  @frames 10
  alias Game.PinBowling.Bowling

  @doc """
  Returns the list of bowling.

  ## Examples

      iex> list_bowling()
      [%Bowling{}, ...]

  """

  def list_bowling do
    Repo.all(Bowling)
  end

  @doc """
  Gets a single bowling.

  Raises `Ecto.NoResultsError` if the Bowling does not exist.

  ## Examples

      iex> get_bowling!(123)
      %Bowling{}

      iex> get_bowling!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bowling!(id), do: Repo.get!(Bowling, id) |> frame_to_struct()

  @doc """
  Creates a bowling.

  ## Examples

      iex> create_bowling(%{field: value})
      {:ok, %Bowling{}}

      iex> create_bowling(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def start_game(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put("state", "started")

    %Bowling{}
    |> Bowling.new_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bowling.

  ## Examples

      iex> update_bowling(bowling, %{field: new_value})
      {:ok, %Bowling{}}

      iex> update_bowling(bowling, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_bowling(%Bowling{} = bowling, attrs) do
    bowling
    |> Bowling.new_changeset(attrs)
    |> Repo.update()
  end

  def update_bowling(%Bowling{} = bowling) do
    frames =
      bowling.frames
      |> Enum.map(fn frame -> Map.from_struct(frame) end)

    bowling
    |> Map.put(:frames, [])
    |> Bowling.changeset(%{"frames" => frames, "state" => bowling.state})
    |> Repo.update()
  end

  @doc """
  Deletes a bowling.

  ## Examples

      iex> delete_bowling(bowling)
      {:ok, %Bowling{}}

      iex> delete_bowling(bowling)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bowling(%Bowling{} = bowling) do
    Repo.delete(bowling)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bowling changes.

  ## Examples

      iex> change_bowling(bowling)
      %Ecto.Changeset{data: %Bowling{}}

  """
  def change_bowling(%Bowling{} = bowling, attrs \\ %{}) do
    Bowling.changeset(bowling, attrs)
  end

  def roll(%Bowling{state: "finished"}, _roll) do
    {:error, "Game is over"}
  end

  def roll(%Bowling{frames: frames} = game, roll) do
    state =
      frames
      |> open
      |> update_state(roll)

    case state do
      {:ok, updated} ->
        state(%{game | frames: updated})
        |> update_bowling()

      error ->
        error
    end
  end

  # Open a new frame when needed.
  defp open([%Frame{state: "started", kind: "open"} | _] = frames), do: frames
  defp open(frames) when length(frames) == @frames, do: frames
  defp open(frames), do: [%Frame{} | frames]

  # update roll for the current frame and fill for the previous two strikes/spares.
  defp update_state(frames, roll) do
    with {head_frames, tail_frames} <- Enum.split(frames, 3),
         {:ok, updated_frames} <- update_state(head_frames, roll, []),
         do: {:ok, Enum.reverse(updated_frames, tail_frames)},
         else: (error -> error)
  end

  defp update_state([], _roll, updated), do: {:ok, updated}

  defp update_state([frame | frames], roll, updated) do
    with {:ok, rolled} <- Frame.roll(frame, roll),
         do: update_state(frames, roll, [rolled | updated]),
         else: (error -> error)
  end

  # check if the game is finished after frames are updated.
  defp state(%Bowling{frames: frames} = game) when length(frames) < @frames, do: game
  defp state(%Bowling{frames: [%Frame{state: "started"} | _]} = game), do: game
  defp state(game), do: %{game | state: "finished"}

  @doc """
    Returns the score of a given at anytime
  """

  def score(%Bowling{frames: frames}) do
    frames |> Enum.map(& &1.score) |> Enum.sum()
  end

  @doc """
    Parce frames to struct
  """
  def frame_to_struct(%Bowling{} = bowling) do
    frames =
      bowling.frames
      |> Enum.map(fn frame ->
        %Frame{
          fill1: frame.fill1,
          fill2: frame.fill2,
          kind: frame.kind,
          roll1: frame.roll1,
          roll2: frame.roll2,
          score: frame.score,
          state: frame.state
        }
      end)

    bowling
    |> Map.put(:frames, frames)
  end
end
