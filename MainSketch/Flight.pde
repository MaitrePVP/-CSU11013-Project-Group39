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

    int delay = hhmmToMinutes(depTime) - hhmmToMinutes(crsDepTime);

    if (delay < -720) delay += 1440;
    if (delay > 720) delay -= 1440;

    return delay;
  }

  String getFlightCode() {
    return trim(airlineCode + " " + flightNumber);
  }

  String getDateKey() {
    return normalizeDateKey(flightDate);
  }

  String getDelayLabel() {
    if (cancelled == 1) return "Cancelled";
    if (diverted == 1) return "Diverted";

    int delay = getDepartureDelay();
    String prefix = delay > 0 ? "+" : "";
    return "Delay " + prefix + delay + " min";
  }
}

String[] flightDates  = new String[0];
int[] flightCounts = new int[0];


class BarChartData {
  String[] labels;
  String[] csvData;

  BarChartData(String[] labels, String[] csvData) {
    this.labels = labels;
    this.csvData = csvData;
  }
}

class ScatterPlotData {
  float[] valuesX;
  float[] valuesY;
  float[] sizes;
  String[] carriers;

  ScatterPlotData(float[] valuesX, float[] valuesY, float[] sizes, String[] carriers) {
    this.valuesX = valuesX;
    this.valuesY = valuesY;
    this.sizes = sizes;
    this.carriers = carriers;
  }
}

BarChartData getBarChartData(ArrayList<Flight> sourceFlights) {
  computeFlightsPerDate(sourceFlights);

  String[] labels = new String[flightDates.length];
  for (int i = 0; i < flightDates.length; i++) {
    labels[i] = formatDateForChartLabel(flightDates[i]);
  }

  String counts = "";
  for (int i = 0; i < flightCounts.length; i++) {
    if (i > 0) counts += ",";
    counts += flightCounts[i];
  }

  String[] csvData = flightCounts.length == 0 ? new String[0] : new String[] { counts };
  return new BarChartData(labels, csvData);
}

ScatterPlotData getScatterPlotData(ArrayList<Flight> sourceFlights) {
  if (sourceFlights == null || sourceFlights.size() == 0) {
    return new ScatterPlotData(new float[0], new float[0], new float[0], new String[0]);
  }

  String[] keys = getDateKeysFromFlights(sourceFlights);
  HashMap<String, Integer> dayOrder = new HashMap<String, Integer>();
  for (int i = 0; i < keys.length; i++) {
    dayOrder.put(keys[i], i + 1);
  }

  int count = sourceFlights.size();
  float[] valuesX = new float[count];
  float[] valuesY = new float[count];
  float[] sizes = new float[count];
  String[] carriers = new String[count];

  for (int i = 0; i < count; i++) {
    Flight f = sourceFlights.get(i);
    String key = f.getDateKey();
    int dayIndex = dayOrder.containsKey(key) ? dayOrder.get(key) : i + 1;
    int minutes = hhmmToMinutes(f.crsDepTime);

    valuesX[i] = dayIndex + minutes / 1440.0;
    valuesY[i] = f.getDepartureDelay();
    sizes[i] = max(1, f.distance);
    carriers[i] = trim(f.airlineCode.equals("") ? "Unknown" : f.airlineCode);
  }

  return new ScatterPlotData(valuesX, valuesY, sizes, carriers);
}

String[] getDateKeysFromFlights(ArrayList<Flight> sourceFlights) {
  HashMap<String, Integer> uniqueDates = new HashMap<String, Integer>();
  for (Flight flight : sourceFlights) {
    String dateKey = flight.getDateKey();
    if (!dateKey.equals("")) uniqueDates.put(dateKey, 1);
  }
  String[] keys = (String[]) uniqueDates.keySet().toArray(new String[0]);
  java.util.Arrays.sort(keys);
  return keys;
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
    String[] row = parseCsvLine(lines[i]);

    if (row.length >= 18) {
      flights.add(new Flight(row));
    }
  }

  dataLoaded = true;
  loadMessage = "Loaded " + flights.size() + " flights from " + filename;
  println(loadMessage);
}

void computeFlightsPerDate(ArrayList<Flight> sourceFlights) {
  HashMap<String, Integer> dateCounts = new HashMap<String, Integer>();

  for (Flight flight : sourceFlights) {
    String dateKey = flight.getDateKey();
    if (dateKey.equals("")) continue;

    if (dateCounts.containsKey(dateKey)) {
      dateCounts.put(dateKey, dateCounts.get(dateKey) + 1);
    } else {
      dateCounts.put(dateKey, 1);
    }
  }

  flightDates = (String[]) dateCounts.keySet().toArray(new String[0]);
  java.util.Arrays.sort(flightDates);

  flightCounts = new int[flightDates.length];
  for (int i = 0; i < flightDates.length; i++) {
    flightCounts[i] = dateCounts.get(flightDates[i]);
  }
}

void filterFlightsByAirport(String airport) {
  filterFlights(airport, "", "");
}

void filterFlightsByDateRange(String start, String end) {
  filterFlights("ALL", normalizeDateKey(start), normalizeDateKey(end));
}

void filterFlights(String airport, String startKey, String endKey) {
  filteredFlights.clear();

  String normalizedStart = normalizeDateKey(startKey);
  String normalizedEnd = normalizeDateKey(endKey);

  for (Flight flight : flights) {
    boolean matchesAirport = airport.equals("ALL") || airport.equals("") ||
                             flight.origin.equals(airport) || flight.dest.equals(airport);

    boolean matchesDate = true;
    String flightDateKey = flight.getDateKey();

    if (!normalizedStart.equals("") && !normalizedEnd.equals("") && !flightDateKey.equals("")) {
      matchesDate = flightDateKey.compareTo(normalizedStart) >= 0 &&
                    flightDateKey.compareTo(normalizedEnd) <= 0;
    }

    if (matchesAirport && matchesDate) {
      filteredFlights.add(flight);
    }
  }
}

void sortFilteredFlightsByLateness() {
  java.util.Collections.sort(filteredFlights, new java.util.Comparator<Flight>() {
    public int compare(Flight left, Flight right) {
      return right.getDepartureDelay() - left.getDepartureDelay();
    }
  });
}

String[] buildAirportOptions(int maxAirports) {
  HashMap<String, Integer> airportCounts = new HashMap<String, Integer>();

  for (Flight flight : flights) {
    addAirportCount(airportCounts, flight.origin);
    addAirportCount(airportCounts, flight.dest);
  }

  String[] airportCodes = (String[]) airportCounts.keySet().toArray(new String[0]);

  for (int i = 0; i < airportCodes.length - 1; i++) {
    for (int j = i + 1; j < airportCodes.length; j++) {
      int currentCount = airportCounts.get(airportCodes[i]);
      int nextCount = airportCounts.get(airportCodes[j]);

      if (nextCount > currentCount ||
          (nextCount == currentCount && airportCodes[j].compareTo(airportCodes[i]) < 0)) {
        String temp = airportCodes[i];
        airportCodes[i] = airportCodes[j];
        airportCodes[j] = temp;
      }
    }
  }

  int optionCount = maxAirports <= 0 ? airportCodes.length : min(maxAirports, airportCodes.length);
  String[] options = new String[optionCount + 1];
  options[0] = "ALL";

  for (int i = 0; i < optionCount; i++) {
    options[i + 1] = airportCodes[i];
  }

  return options;
}

void addAirportCount(HashMap<String, Integer> airportCounts, String airportCode) {
  if (airportCode == null) return;

  airportCode = trim(airportCode);
  if (airportCode.equals("")) return;

  if (airportCounts.containsKey(airportCode)) {
    airportCounts.put(airportCode, airportCounts.get(airportCode) + 1);
  } else {
    airportCounts.put(airportCode, 1);
  }
}

String[] getAvailableDateKeys() {
  return getDateKeysFromFlights(flights);
}

String[] parseCsvLine(String line) {
  ArrayList<String> values = new ArrayList<String>();
  StringBuilder currentValue = new StringBuilder();
  boolean insideQuotes = false;

  for (int i = 0; i < line.length(); i++) {
    char currentChar = line.charAt(i);

    if (currentChar == '"') {
      if (insideQuotes && i + 1 < line.length() && line.charAt(i + 1) == '"') {
        currentValue.append('"');
        i++;
      } else {
        insideQuotes = !insideQuotes;
      }
    } else if (currentChar == ',' && !insideQuotes) {
      values.add(currentValue.toString());
      currentValue.setLength(0);
    } else {
      currentValue.append(currentChar);
    }
  }

  values.add(currentValue.toString());
  return values.toArray(new String[0]);
}

String normalizeDateKey(String rawDate) {
  String cleanedDate = trim(rawDate);
  if (cleanedDate.equals("")) return "";

  int spaceIndex = cleanedDate.indexOf(' ');
  if (spaceIndex > 0) {
    cleanedDate = cleanedDate.substring(0, spaceIndex);
  }

  if (cleanedDate.length() == 8 && cleanedDate.indexOf('/') == -1 && cleanedDate.indexOf('-') == -1) {
    return cleanedDate;
  }

  if (cleanedDate.indexOf('/') != -1) {
    String[] parts = split(cleanedDate, '/');
    if (parts.length == 3) {
      String month = padDatePart(parts[0]);
      String day = padDatePart(parts[1]);
      String year = trim(parts[2]);
      return year + month + day;
    }
  }

  if (cleanedDate.indexOf('-') != -1) {
    String[] parts = split(cleanedDate, '-');
    if (parts.length == 3) {
      String year = trim(parts[0]);
      String month = padDatePart(parts[1]);
      String day = padDatePart(parts[2]);
      return year + month + day;
    }
  }

  return cleanedDate;
}

String padDatePart(String value) {
  value = trim(value);
  return value.length() == 1 ? "0" + value : value;
}

String formatDateForUi(String dateKey) {
  String normalizedDate = normalizeDateKey(dateKey);
  if (normalizedDate.length() != 8) return normalizedDate;

  String year = normalizedDate.substring(0, 4);
  String month = normalizedDate.substring(4, 6);
  String day = normalizedDate.substring(6, 8);
  return month + "/" + day + "/" + year;
}

String formatDateForChartLabel(String dateKey) {
  String normalizedDate = normalizeDateKey(dateKey);
  if (normalizedDate.length() != 8) return normalizedDate;

  String month = normalizedDate.substring(4, 6);
  String day = normalizedDate.substring(6, 8);
  return month + "/" + day;
}

int hhmmToMinutes(int hhmm) {
  int hours = hhmm / 100;
  int minutes = hhmm % 100;
  return hours * 60 + minutes;
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
