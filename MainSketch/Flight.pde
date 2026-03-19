class Flight {
  String flightDate;
  String airlineCode;
  String flightNumber;
  String origin;
  String originCity;
  String originState;
  int originWac;
  String dest;
  String destCity;
  String destState;
  int destWac;
  int crsDepTime;
  int depTime;
  int crsArrTime;
  int arrTime;
  int cancelled;
  int diverted;
  int distance;

  Flight(String[] row) {
    flightDate   = safeGet(row, 0);
    airlineCode  = safeGet(row, 1);
    flightNumber = safeGet(row, 2);
    origin       = safeGet(row, 3);
    originCity   = safeGet(row, 4);
    originState  = safeGet(row, 5);
    originWac    = safeInt(safeGet(row, 6));
    dest         = safeGet(row, 7);
    destCity     = safeGet(row, 8);
    destState    = safeGet(row, 9);
    destWac      = safeInt(safeGet(row, 10));
    crsDepTime   = safeInt(safeGet(row, 11));
    depTime      = safeInt(safeGet(row, 12));
    crsArrTime   = safeInt(safeGet(row, 13));
    arrTime      = safeInt(safeGet(row, 14));
    cancelled    = safeInt(safeGet(row, 15));
    diverted     = safeInt(safeGet(row, 16));
    distance     = safeInt(safeGet(row, 17));
  }

  int getDepartureDelay() {
    if (cancelled == 1 || depTime == 0 || crsDepTime == 0) return 0;
    return depTime - crsDepTime;
  }

  String getFlightCode() {
    return airlineCode + flightNumber;
  }
}

void loadFlightData(String filename) {
  String[] lines = loadStrings(filename);

  if (lines == null || lines.length <= 1) {
    dataLoaded = false;
    loadMessage = "Could not load " + filename;
    println(loadMessage);
    return;
  }

  flights.clear();

  for (int i = 1; i < lines.length; i++) {
    String[] row = split(lines[i], ',');

    if (row.length >= 18) {
      Flight f = new Flight(row);
      flights.add(f);
    }
  }

  dataLoaded = true;
  loadMessage = "Loaded " + flights.size() + " flights from " + filename;
  println(loadMessage);
}

void filterFlightsByAirport(String airport) {
  filteredFlights.clear();

  for (Flight f : flights) {
    if (f.origin.equals(airport) || f.dest.equals(airport)) {
      filteredFlights.add(f);
    }
  }
}

void filterFlightsByDateRange(String start, String end) {
  filteredFlights.clear();

  for (Flight f : flights) {
    if (f.flightDate.compareTo(start) >= 0 && f.flightDate.compareTo(end) <= 0) {
      filteredFlights.add(f);
    }
  }
}

void sortFilteredFlightsByLateness() {
  for (int i = 0; i < filteredFlights.size() - 1; i++) {
    for (int j = i + 1; j < filteredFlights.size(); j++) {
      if (filteredFlights.get(j).getDepartureDelay() > filteredFlights.get(i).getDepartureDelay()) {
        Flight temp = filteredFlights.get(i);
        filteredFlights.set(i, filteredFlights.get(j));
        filteredFlights.set(j, temp);
      }
    }
  }
}

String safeGet(String[] arr, int index) {
  if (index >= 0 && index < arr.length) {
    return trim(arr[index]);
  }
  return "";
}

int safeInt(String s) {
  s = trim(s);
  if (s.equals("")) return 0;

  try {
    return Integer.parseInt(s);
  } 
  catch (Exception e) {
    return 0;
  }
}
