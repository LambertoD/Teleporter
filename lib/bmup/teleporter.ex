defmodule Bmup.Teleporter do

  def add_route(current_routes, key, value ) do
    route1 = map_adder(%{}, key, [value])
    route2 = map_adder(%{}, value, [key])

    Map.merge(route1, route2, &map_merger/3)
    |> Map.merge(current_routes, &map_merger/3)
  end

  def teleport_options_with_jump_count(routes, city, number) do
    case number do
      1 -> routes[city]
      2 -> get_hops(routes, city)
    end
  end

  def get_hops(routes, city) do
    next_hops =
      routes[city] |> Enum.map(fn hop -> routes[hop] end)

    all_hops = routes[city] ++ next_hops
    List.flatten(all_hops)
    |> Enum.uniq
    |> Kernel.-- [city]
  end

  defp map_merger(_k, v1, v2) do
    [v1, v2] |> Enum.concat
  end

  defp map_adder(map, key, value) do
    Map.put(map, key, value)
  end
end
