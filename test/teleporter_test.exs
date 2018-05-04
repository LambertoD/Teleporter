defmodule TeleporterTest do
  use ExUnit.Case

  alias Bmup.Teleporter

  test "Add a route to empty portal" do
    route = Teleporter.add_route(%{}, "Washington", "Atlanta")
    assert route == %{"Washington" => ["Atlanta"], "Atlanta" => ["Washington"]}
  end

  test "Add a route to existing portal, non-existing key" do
    route = Teleporter.add_route(%{"Baltimore" => ["Philadelphia"], "Philadelphia" => "Baltimore"}, "Washington", "Atlanta")
    assert route == %{"Washington" => ["Atlanta"], "Atlanta" => ["Washington"], "Baltimore" => ["Philadelphia"], "Philadelphia" => "Baltimore"}
  end

  test "Add a route to existing portal, existing key" do
    route = Teleporter.add_route(%{"Washington" => ["Baltimore"], "Baltimore" => ["Washington"]}, "Washington", "Atlanta")
    assert route == %{"Washington" => ["Atlanta", "Baltimore"], "Baltimore" => ["Washington"], "Atlanta" => ["Washington"]}
  end

  test "Add full teleport route system" do
    generated_routes =
    Teleporter.add_route(%{}, "Washington", "Baltimore")
    |> Teleporter.add_route("Washington", "Atlanta")
    |> Teleporter.add_route("Baltimore", "Philadelphia")
    |> Teleporter.add_route("Philadelphia", "New York")
    |> Teleporter.add_route("Los Angeles", "San Francisco")
    |> Teleporter.add_route("San Francisco", "Oakland")
    |> Teleporter.add_route("Los Angeles", "Oakland")
    |> Teleporter.add_route("Seattle", "New York")
    |> Teleporter.add_route("Seattle", "Baltimore")

    expected_complete_routes = %{
      "Atlanta" => ["Washington"],
      "Washington" => ["Atlanta", "Baltimore"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"]}

    assert expected_complete_routes == generated_routes

  end

  test "Get 1 jump hop route" do
    routes = %{
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Washington"],
      "Washington" => ["Atlanta", "Baltimore"]
    }

    assert Teleporter.teleport_options_with_jump_count(routes, "Washington", 1) == ["Atlanta", "Baltimore"]
  end

  test "Get another 1 jump hop route" do
    routes = %{
      "Atlanta" => ["Washington"],
      "Washington" => ["Atlanta", "Baltimore"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"]}

    assert Teleporter.teleport_options_with_jump_count(routes, "Seattle", 1) == ["Baltimore", "New York"]
  end

  test "Get another 2 jump hop route" do
    routes = %{
      "Atlanta" => ["Washington"],
      "Washington" => ["Atlanta", "Baltimore"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"]}

    assert Teleporter.teleport_options_with_jump_count(routes, "Seattle", 2) == ["Baltimore", "New York", "Philadelphia", "Washington"]
  end
end
