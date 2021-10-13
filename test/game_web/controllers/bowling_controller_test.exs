defmodule GameWeb.BowlingControllerTest do
  use GameWeb.ConnCase

  alias Game.PinBowling
  alias Game.PinBowling.Bowling

  @create_attrs %{
    "username" => "user1"
  }
  @update_attrs %{
    "username" => "user2"
  }
  @invalid_attrs %{username: nil}

  def fixture(:bowling) do
    {:ok, bowling} = PinBowling.start_game(@create_attrs)
    bowling
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all bowling", %{conn: conn} do
      conn = get(conn, Routes.bowling_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "start game" do
    test "renders bowling when data is valid", %{conn: conn} do
      conn = post(conn, Routes.bowling_path(conn, :create), bowling: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.bowling_path(conn, :show, id))

      assert %{
               "id" => _,
               "username" => "user1",
               "state" => "started",
               "frames" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.bowling_path(conn, :create), bowling: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "bowling roll" do
    setup [:create_bowling]

    test "renders bowling when data is valid", %{conn: conn, bowling: %Bowling{id: id} = _bowling} do
      response =
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 10
        })
        |> json_response(200)

      assert %{
               "id" => ^id,
               "frames" => [
                 %{
                   "fill1" => nil,
                   "fill2" => nil,
                   "kind" => "strike",
                   "roll1" => 10,
                   "roll2" => nil,
                   "score" => 10,
                   "state" => "started"
                 }
               ]
             } = response["data"]
    end
  end

  describe "full game bowling roll" do
    setup [:create_bowling]

    test "renders bowling start if game ended", %{
      conn: conn,
      bowling: %Bowling{id: id} = _bowling
    } do
      1..9
      |> Enum.map(fn _game ->
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 10
        })
        |> json_response(200)
      end)

      1..4
      |> Enum.map(fn _game ->
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 5
        })
        |> json_response(200)
      end)

      response =
        conn
        |> get(Routes.bowling_path(conn, :score, id))
        |> json_response(200)

      assert %{"score" => 270} == response
    end

    test "renders bowling when strike [ perfect game ]", %{
      conn: conn,
      bowling: %Bowling{id: id} = _bowling
    } do
      1..12
      |> Enum.map(fn _game ->
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 10
        })
        |> json_response(200)
      end)

      response =
        conn
        |> get(Routes.bowling_path(conn, :score, id))
        |> json_response(200)

      assert %{"score" => 300} == response
    end

    test "renders bowling when spar", %{conn: conn, bowling: %Bowling{id: id} = _bowling} do
      1..9
      |> Enum.map(fn _game ->
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 10
        })
        |> json_response(200)
      end)

      1..3
      |> Enum.map(fn _game ->
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 5
        })
        |> json_response(200)
      end)

      response =
        conn
        |> get(Routes.bowling_path(conn, :score, id))
        |> json_response(200)

      assert %{"score" => 270} == response
    end
  end

  describe "score game " do
    setup [:create_bowling]

    test "renders bowling when data is valid", %{conn: conn, bowling: %Bowling{id: id} = _bowling} do
      response =
        conn
        |> post(Routes.bowling_path(conn, :roll), %{
          "id" => id,
          "roll" => 10
        })
        |> json_response(200)

      assert %{
               "id" => ^id,
               "frames" => [
                 %{
                   "fill1" => nil,
                   "fill2" => nil,
                   "kind" => "strike",
                   "roll1" => 10,
                   "roll2" => nil,
                   "score" => 10,
                   "state" => "started"
                 }
               ]
             } = response["data"]

      response =
        conn
        |> get(Routes.bowling_path(conn, :score, id))
        |> json_response(200)

      assert %{"score" => 10} == response
    end
  end

  describe "update bowling" do
    setup [:create_bowling]

    test "renders bowling when data is valid", %{conn: conn, bowling: %Bowling{id: id} = bowling} do
      conn = put(conn, Routes.bowling_path(conn, :update, bowling), bowling: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.bowling_path(conn, :show, id))

      assert %{
               "id" => _,
               "username" => "user2",
               "state" => "started",
               "frames" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, bowling: bowling} do
      conn = put(conn, Routes.bowling_path(conn, :update, bowling), bowling: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete bowling" do
    setup [:create_bowling]

    test "deletes chosen bowling", %{conn: conn, bowling: bowling} do
      conn = delete(conn, Routes.bowling_path(conn, :delete, bowling))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Routes.bowling_path(conn, :show, bowling))
      end)
    end
  end

  defp create_bowling(_) do
    bowling = fixture(:bowling)
    %{bowling: bowling}
  end
end
