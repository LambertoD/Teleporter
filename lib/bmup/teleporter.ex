defmodule Bmup.Teleporter do

  def add_route(current_routes, key, value ) do

    route1 = map_adder(%{}, key, [value])
    route2 = map_adder(%{}, value, [key])
    cities = [key, value] |> Enum.sort

    new_routes =
      Map.merge(route1, route2, &map_merger/3)
      |> Map.merge(current_routes, &map_merger/3)

    if Map.has_key?(new_routes, "cities") do
      updated_cities = [cities | new_routes["cities"]]
        |> List.flatten |> Enum.uniq |> Enum.sort
      %{new_routes | "cities" => updated_cities}
    else
      Map.put(new_routes, "cities", cities)
    end
  end

  def teleport_options_with_jump_count(routes, city, number) do
    case number do
      1 -> routes[city]
      2 -> get_hops(routes, city)
      _ -> get_hops(routes, city, [])
    end
  end

  def get_hops(routes, city) do
    next_hops =
      routes[city] |> Enum.map(fn hop -> routes[hop] end)

    merge_hops(routes, city, next_hops)
  end

  def get_hops(routes, city, current_hops) do
    [ get_hops(routes, city) | current_hops]
  end

  def merge_hops(routes, city, next_hops) do
    all_hops = routes[city] ++ next_hops
    List.flatten(all_hops)
    |> Enum.uniq
    |> Kernel.-- [city]
  end

  def can_beam_to_city?(routes, current_city, desired_city) do
    # search routes =>  recurse through get_hops until end
    # build route path
    # Enum.member?(full_route, desired_city)
    true
  end

  defp map_merger(_k, v1, v2) do
    [v1, v2] |> Enum.concat
  end

  defp map_adder(map, key, value) do
    Map.put(map, key, value)
  end
end
