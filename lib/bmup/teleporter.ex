defmodule Bmup.Teleporter do

  def add_route(current_routes, key, value ) do

    route1 = map_adder(%{}, key, [value])
    route2 = map_adder(%{}, value, [key])
    cities = [key, value] |> Enum.sort
    lines = cities |> check_lines(current_routes)

    Map.merge(route1, route2, &map_merger/3)
    |> Map.merge(current_routes, &map_merger/3)
    |> add_cities(cities)
    |> add_lines(lines)
  end

  def check_lines(city_list, routes) do
    if Map.has_key?(routes, "lines") do
      update_lines(routes["lines"], city_list)
    else
      %{"1" => city_list}
    end
  end

  @doc """
    Check all existing lines and re-create as necessary as
    new connections are made between cities.
    If cities in city_list are not found in existing lines then
    a new line is created for that city_list.
    If cities in city_list are found in existing lines then
    the line is updated to include cities in city_list.
    If cities in city_list are found separately in other lines then
    the 2 lines are merged into 1 line.

    [["Atlanta", "Washington"], ["Baltimore", "Philadelphia"]]
    into
    %{"1" => ["Atlanta", "Washington"],
      "2" => ["Baltimore", "Philadelphia"]}
    OR
    [["Atlanta", "Washington"], ["Baltimore", "Philadelphia"]]
      with city_list ["Washington", "Baltimore"]
    into
    %{"1" => ["Atlanta", "Baltimore", " "Washington", "Philadelphia"],
  """
  def update_lines(lines, city_list) do
    # use reduce to make lines,  use MapSet as function helper
    lines
    |> Map.values
    |> Enum.reduce(%{}, fn(x, line_map) -> recreate_lines(x, city_list, line_map) end )
  end

  def recreate_lines(route_line, cities, lines) do
    if MapSet.disjoint?(MapSet.new(route_line), MapSet.new(cities)) do
      if Enum.empty? lines do
        Map.put_new(lines, "1", route_line)
        |> Map.put_new("2", cities)
      else
       last_key = Map.keys(lines) |> List.last
       new_key = (String.to_integer(last_key) + 1) |> Integer.to_string
       Map.put_new(lines, new_key, route_line)
      end
    else
      if Enum.empty? lines do
       new_line =
        MapSet.union(MapSet.new(route_line), MapSet.new(cities))
        |> MapSet.to_list
       Map.put_new(lines, "1", new_line)
      else
        current_routes = Map.values(lines) |> List.flatten
         new_line =
          MapSet.union(MapSet.new(current_routes), MapSet.new(route_line))
          |> MapSet.to_list
         %{ lines | "1" => new_line}
      end
    end
  end

  def add_cities(routes, cities) do
    if Map.has_key?(routes, "cities") do
      # updated_cities = MapSet.put(MapSet.new(routes["cities"]), cities)
      updated_cities = [cities | routes["cities"]]
        |> List.flatten |> Enum.uniq |> Enum.sort
      %{routes | "cities" => updated_cities}
    else
      Map.put(routes, "cities", cities)
    end
  end

  def add_lines(routes, lines) do
    if Map.has_key?(routes, "lines") do
      %{routes | "lines" => lines}
    else
      Map.put(routes, "lines", lines)
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
    |> (Kernel.-- [city])
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
