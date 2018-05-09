defmodule TeleporterTest do
  use ExUnit.Case

  alias Bmup.Teleporter

  test "Add a route to empty portal" do
    route = Teleporter.add_route(%{}, "Washington", "Atlanta")
    assert route == %{
      "Washington" => ["Atlanta"],
      "Atlanta" => ["Washington"],
      "cities_in_system" => ["Atlanta", "Washington"],
      "port_routes" => %{"1" => %{route_path: ["Atlanta", "Washington"]}}
      }
  end

  test "Add a route to existing portal, non-existing key" do
    route = Teleporter.add_route(%{"Baltimore" => ["Philadelphia"], "Philadelphia" => ["Baltimore"],
      "cities_in_system" => ["Baltimore", "Philadelphia"],
      "port_routes" => %{"1" => %{route_path: ["Baltimore", "Philadelphia"]}}},
      "Atlanta", "Washington"
      )
    assert route == %{
      "Washington" => ["Atlanta"],
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Philadelphia"],
      "Philadelphia" => ["Baltimore"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Philadelphia", "Washington"] ,
      "port_routes" => %{"2" => %{route_path: ["Atlanta", "Washington"]},
                   "1" => %{route_path: ["Baltimore",  "Philadelphia"]}}
    }
  end

  test "Add a route to existing portal, existing key" do
    route = Teleporter.add_route(%{"Washington" => ["Baltimore"], "Baltimore" => ["Washington"],
      "cities_in_system" => ["Baltimore", "Washington"],
      "port_routes" => %{"1" => %{route_path: ["Baltimore", "Washington"]}}},
      "Washington", "Atlanta")

    assert route == %{
      "Washington" => ["Atlanta", "Baltimore"],
      "Baltimore" => ["Washington"],
      "Atlanta" => ["Washington"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Washington"],
      "port_routes" => %{"1" => %{route_path: ["Atlanta", "Baltimore", "Washington"]}}
      }
  end

  test "Add full joint teleport route system" do
    generated_routes =
    Teleporter.add_route(%{}, "Washington", "Baltimore")
    |> Teleporter.add_route("Washington", "Atlanta")
    |> Teleporter.add_route("Baltimore", "Philadelphia")
    |> Teleporter.add_route("Philadelphia", "New York")

    expected_complete_routes =  %{
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Philadelphia", "Washington"],
      "New York" => ["Philadelphia"],
      "Philadelphia" => ["New York", "Baltimore"],
      "Washington" => ["Atlanta", "Baltimore"],
      "cities_in_system" => ["Atlanta", "Baltimore", "New York",
       "Philadelphia", "Washington"],
      "port_routes" => %{
        "1" => %{route_path: ["Atlanta", "Baltimore", "New York",
           "Philadelphia", "Washington"]
        }
      }
    }
    assert expected_complete_routes == generated_routes
  end

  test "Add 2 separately joined teleport route systems" do
    generated_routes =
    Teleporter.add_route(%{}, "Washington", "Baltimore")
    |> Teleporter.add_route("Washington", "Atlanta")
    |> Teleporter.add_route("Los Angeles", "San Francisco")
    |> Teleporter.add_route("San Francisco", "Oakland")

    expected_complete_routes = %{
      "Atlanta" => ["Washington"],
      "Washington" => ["Atlanta", "Baltimore"],
      "Baltimore" => ["Washington"],
      "Los Angeles" => ["San Francisco"],
      "Oakland" => ["San Francisco"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Los Angeles",
               "Oakland", "San Francisco", "Washington"],
      "port_routes" => %{"1" => %{route_path: ["Atlanta", "Baltimore", "Washington"]},
                          "2" => %{route_path: ["Los Angeles", "Oakland", "San Francisco"]
                        }
      }
    }
    assert expected_complete_routes == generated_routes
  end

  # test "BUG:  Add 2 separately joined teleport route systems with requests non in sequence" do
  #   generated_routes =
  #   Teleporter.add_route(%{}, "Washington", "Baltimore")
  #   |> Teleporter.add_route("Los Angeles", "San Francisco")
  #   |> Teleporter.add_route("Washington", "Atlanta")
  #   |> Teleporter.add_route("San Francisco", "Oakland")

  #   expected_complete_routes = %{
  #     "Atlanta" => ["Washington"],
  #     "Washington" => ["Atlanta", "Baltimore"],
  #     "Baltimore" => ["Washington"],
  #     "Los Angeles" => ["San Francisco"],
  #     "Oakland" => ["San Francisco"],
  #     "San Francisco" => ["Oakland", "Los Angeles"],
  #     "cities_in_system" => ["Atlanta", "Baltimore", "Los Angeles",
  #              "Oakland", "San Francisco", "Washington"],
  #     "port_routes" => %{"1" => %{route_path: ["Atlanta", "Baltimore", "Washington"]},
  #                         "2" => %{route_path: ["Los Angeles", "Oakland", "San Francisco"]
  #                       }
  #     }
  #   }
  #   assert expected_complete_routes == generated_routes
  # end

  test "Add full teleport route systems" do
    generated_routes =
    Teleporter.add_route(%{}, "Washington", "Baltimore")
    |> Teleporter.add_route("Washington", "Atlanta")
    |> Teleporter.add_route("Baltimore", "Philadelphia")
    |> Teleporter.add_route("Philadelphia", "New York")
    |> Teleporter.add_route("Seattle", "New York")
    |> Teleporter.add_route("Seattle", "Baltimore")
    |> Teleporter.add_route("Los Angeles", "San Francisco")
    |> Teleporter.add_route("San Francisco", "Oakland")
    |> Teleporter.add_route("Los Angeles", "Oakland")

    expected_complete_routes = %{
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"],
      "Washington" => ["Atlanta", "Baltimore"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Los Angeles",
       "New York", "Oakland", "Philadelphia", "San Francisco",
       "Seattle", "Washington"],
      "port_routes" => %{
        "1" => %{route_path: ["Atlanta", "Baltimore", "New York",
           "Philadelphia", "Seattle", "Washington"]
        },
        "2" => %{route_path: ["Los Angeles", "Oakland", "San Francisco"]
        }
      }
    }

    assert expected_complete_routes == generated_routes

  end

  test "1 and 2 jump hop route" do
    routes = %{
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"],
      "Washington" => ["Atlanta", "Baltimore"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Los Angeles",
       "New York", "Oakland", "Philadelphia", "San Francisco",
       "Seattle", "Washington"],
      "port_routes" => %{
        "1" => %{route_path: ["Atlanta", "Baltimore", "New York",
           "Philadelphia", "Seattle", "Washington"]
        },
        "2" => %{route_path: ["Los Angeles", "Oakland", "San Francisco"]
        }
      }
    }
    assert Teleporter.teleport_options_with_jump_count(routes, "Washington", 1) == ["Atlanta", "Baltimore"]
    assert Teleporter.teleport_options_with_jump_count(routes, "Seattle", 1) == ["Baltimore", "New York"]
    assert Teleporter.teleport_options_with_jump_count(routes, "Seattle", 2) == ["Baltimore", "New York", "Philadelphia", "Washington"]
  end

  test "Can I hop to city from a New York to Atlanta" do
    routes = %{
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"],
      "Washington" => ["Atlanta", "Baltimore"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Los Angeles",
       "New York", "Oakland", "Philadelphia", "San Francisco",
       "Seattle", "Washington"],
      "port_routes" => %{
        "1" => %{route_path: ["Atlanta", "Baltimore", "New York",
           "Philadelphia", "Seattle", "Washington"]
        },
        "2" => %{route_path: ["Los Angeles", "Oakland", "San Francisco"]
        }
      }
    }

    assert Teleporter.can_beam_to_city?(routes, "New York", "Atlanta") == true
  end

  test "Can I hop to city from a Oakland to Atlanta" do
    routes = %{
      "Atlanta" => ["Washington"],
      "Baltimore" => ["Seattle", "Philadelphia", "Washington"],
      "Los Angeles" => ["Oakland", "San Francisco"],
      "New York" => ["Seattle", "Philadelphia"],
      "Oakland" => ["Los Angeles", "San Francisco"],
      "Philadelphia" => ["New York", "Baltimore"],
      "San Francisco" => ["Oakland", "Los Angeles"],
      "Seattle" => ["Baltimore", "New York"],
      "Washington" => ["Atlanta", "Baltimore"],
      "cities_in_system" => ["Atlanta", "Baltimore", "Los Angeles",
       "New York", "Oakland", "Philadelphia", "San Francisco",
       "Seattle", "Washington"],
      "port_routes" => %{
        "1" => %{route_path: ["Atlanta", "Baltimore", "New York",
           "Philadelphia", "Seattle", "Washington"]
        },
        "2" => %{route_path: ["Los Angeles", "Oakland", "San Francisco"]
        }
      }
    }

    assert Teleporter.can_beam_to_city?(routes, "Oakland", "Atlanta") == false
  end
end
