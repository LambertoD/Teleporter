defmodule Bmup.Teleporter do

  def add_route(port_system, key, value ) do

    route1 = map_adder(%{}, key, [value])
    route2 = map_adder(%{}, value, [key])
    cities_in_system = [key, value] |> Enum.sort
    port_routes = cities_in_system |> check_lines(port_system)

    Map.merge(route1, route2, &map_merger/3)
    |> Map.merge(port_system, &map_merger/3)
    |> add_cities(cities_in_system)
    |> add_port_routes(port_routes)
  end

  def check_lines(city_list, routes) do
    if Map.has_key?(routes, "port_routes") do
      update_port_routes(routes["port_routes"], city_list)
    else
      %{"1" => city_list}
    end
  end

  @doc """
    Check all existing port_routes and re-create as necessary as
    new connections are made between cities.
    If cities in city_list are not found in existing port_routes then
    a new port_route is created for that city_list.
    If cities in city_list are found in existing port_routes then
    the port_route is updated to include cities in city_list.
    If cities in city_list are found separately in other port_routes then
    the 2 port_routes are merged into 1 port_route.

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
  def update_port_routes(port_routes, city_list) do
    # mark current routes that have common members with city list
    marked_routes =
      Enum.map(port_routes, fn {k,v} -> cities_in_current_port_routes({k,v}, city_list) end)
    # based on marked routes, merge those that are matching    
    merged_matched_routes =
      Enum.reduce(marked_routes, 
                  %{}, 
                  fn(x, acc) -> 
                     merge_cities({Map.keys(x),Map.values(x)}, acc, city_list) 
                  end)
    # trim temporary keys in port_routes

  end

  def cities_in_current_port_routes({key, value}, city_list) do
    if MapSet.disjoint?(MapSet.new(value.route_path), MapSet.new(city_list)) do
      Map.new([{key, value}])
    else
      updated_route = Map.new([{:route_path, value.route_path}, {:status, :match}]) 
      Map.new([{key, updated_route}])
    end
  end

  def merge_cities({[k],[v]}, acc, city_list) do
    current_map = Map.new([{k, v}])
    if v.status == :match do
      new_route_path = MapSet.union(MapSet.new(v.route_path), MapSet.new(city_list))
        |> MapSet.to_list 

      {acc_route_path, key_values} = 
          if Enum.empty? acc or map_marked_matched?(acc) do
            {new_route_path, [k]}
          else
            {_, temp_value} = 
              Enum.filter(acc, fn {acc_key, acc_value} -> acc_value.status == :match end)
              |> List.first

            key_list = [k|temp_value.key_values]
            route_path = 
              MapSet.union(MapSet.new(new_route_path), MapSet.new(temp_value.route_path))
              |> MapSet.to_list
          end

      route_map = Map.new([{:route_path, acc_route_path},
                           {:status, :match}, 
                           {:key_values, key_values}])
      new_key = Enum.sort(key_values) |> List.first

      Map.put(acc, new_key, route_map)
    else
      current_map
    end
  end 

  defp map_marked_matched?(map) do
    map |> Map.values |> Enum.all?(fn y -> y.status == :nil end)
  end

  def add_cities(port_system, cities) do
    if Map.has_key?(port_system, "cities_in_system") do
      updated_cities = 
        MapSet.put(MapSet.new(port_system["cities_in_system"]), cities)
        |> MapSet.to_list |> List.flatten |> Enum.sort

      %{port_system | "cities_in_system" => updated_cities}
    else
      Map.put(port_system, "cities_in_system", cities)
    end
  end

  def add_port_routes(routes, port_routes) do
    if Map.has_key?(routes, "port_routes") do
      %{routes | "port_routes" => port_routes}
    else
      Map.put(routes, "port_routes", port_routes)
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
