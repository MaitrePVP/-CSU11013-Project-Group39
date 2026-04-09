// basically each row from the CSV becomes one of these objects
// every field maps to a column in the dataset
class Flight {
  String flightDate;       // when the flight was (or was supposed to be)
  String airlineCode;      // like "AA" for American, "DL" for Delta, etc.
  String flightNumber;     // the actual flight number, e.g. "1234"
  String origin;           // airport code where it took off from
  String originCity;       // city name for the origin
  String originState;      // state abbreviation for the origin
  int originWac;           // some government region code honestly not sure what WAC stands for
  String dest;             // airport code where it's headed
  String destCity;         // destination city name
  String destState;        // destination state
  int destWac;             // same region code thing but for destination
  int crsDepTime;          // the scheduled departure time (in hhmm format like 1430 = 2:30pm)
  int depTime;             // when it actually departed
  int crsArrTime;          // scheduled arrival
  int arrTime;             // actual arrival
  int cancelled;           // 1 if it got cancelled, 0 if not
  int diverted;            // 1 if it got diverted somewhere else
  int distance;            // how far the flight is in miles

  // takes a row from the CSV and pulls out each column
  // using safeGet so it doesn't crash if a column is missing or empty
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

  // figures out how late (or early) the flight departed in minutes
  // positive = late, negative = early
  int getDepartureDelay() {
    // if it was cancelled or we don't have real times, just say 0
    if (cancelled == 1 || depTime == 0 || crsDepTime == 0) return 0;

    int delay = hhmmToMinutes(depTime) - hhmmToMinutes(crsDepTime);

    // these handle the midnight wraparound edge case
    // e.g. scheduled at 11:50pm, departed at 12:10am — that's a 20 min delay not a -1420 min one
    if (delay < -720) delay += 1440;
    if (delay > 720) delay -= 1440;

    return delay;
  }

  // just sticks the airline code and flight number together like "AA 1234"
  String getFlightCode() {
    return trim(airlineCode + " " + flightNumber);
  }

  // normalises the date into a sortable key so we can group/compare dates easily
  String getDateKey() {
    return normalizeDateKey(flightDate);
  }

  // returns a nice readable label for how delayed the flight was
  // or just says "Cancelled"/"Diverted" if that happened
  String getDelayLabel() {
    if (cancelled == 1) return "Cancelled";
    if (diverted == 1) return "Diverted";

    int delay = getDepartureDelay();
    String prefix = delay > 0 ? "+" : "";  // add a plus sign so it's obvious it's late
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

  HashMap<String, Integer> dayOrder = buildScatterDayOrder(sourceFlights);

  int count = sourceFlights.size();
  float[] valuesX = new float[count];
  float[] valuesY = new float[count];
  float[] sizes = new float[count];
  String[] carriers = new String[count];

  for (int i = 0; i < count; i++) {
    Flight f = sourceFlights.get(i);
    valuesX[i] = getScatterPlotXValue(f, dayOrder);
    valuesY[i] = f.getDepartureDelay();
    sizes[i] = max(1, f.distance);
    carriers[i] = trim(f.airlineCode.equals("") ? "Unknown" : f.airlineCode);
  }

  return new ScatterPlotData(valuesX, valuesY, sizes, carriers);
}

HashMap<String, Integer> buildScatterDayOrder(ArrayList<Flight> sourceFlights) {
  String[] keys = getDateKeysFromFlights(sourceFlights);
  HashMap<String, Integer> dayOrder = new HashMap<String, Integer>();
  for (int i = 0; i < keys.length; i++) {
    dayOrder.put(keys[i], i + 1);
  }
  return dayOrder;
}

float getScatterPlotXValue(Flight flight, HashMap<String, Integer> dayOrder) {
  if (flight == null) return 0;

  String key = flight.getDateKey();
  int dayIndex = (dayOrder != null && dayOrder.containsKey(key)) ? dayOrder.get(key) : 1;
  int minutes = hhmmToMinutes(flight.crsDepTime);
  return dayIndex + minutes / 1440.0;
}

float[] getScatterSliderValues(ArrayList<Flight> sourceFlights) {
  if (sourceFlights == null || sourceFlights.size() == 0) {
    return new float[0];
  }

  HashMap<String, Integer> dayOrder = buildScatterDayOrder(sourceFlights);
  java.util.TreeSet<Float> uniqueValues = new java.util.TreeSet<Float>();

  for (Flight flight : sourceFlights) {
    uniqueValues.add(getScatterPlotXValue(flight, dayOrder));
  }

  float[] values = new float[uniqueValues.size()];
  int index = 0;
  for (Float value : uniqueValues) {
    values[index++] = value.floatValue();
  }
  return values;
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

    boolean matchesDate = isFlightDateInRange(flight.getDateKey(), normalizedStart, normalizedEnd);

    if (matchesAirport && matchesDate) {
      filteredFlights.add(flight);
    }
  }
}

ArrayList<Flight> getFlightsInDateRange(ArrayList<Flight> sourceFlights, String startKey, String endKey) {
  ArrayList<Flight> matchingFlights = new ArrayList<Flight>();
  if (sourceFlights == null) return matchingFlights;

  String normalizedStart = normalizeDateKey(startKey);
  String normalizedEnd = normalizeDateKey(endKey);

  for (Flight flight : sourceFlights) {
    if (isFlightDateInRange(flight.getDateKey(), normalizedStart, normalizedEnd)) {
      matchingFlights.add(flight);
    }
  }

  return matchingFlights;
}

ArrayList<Flight> getFlightsInScatterRange(ArrayList<Flight> sourceFlights, float startX, float endX) {
  ArrayList<Flight> matchingFlights = new ArrayList<Flight>();
  if (sourceFlights == null) return matchingFlights;

  HashMap<String, Integer> dayOrder = buildScatterDayOrder(sourceFlights);
  float minX = min(startX, endX);
  float maxX = max(startX, endX);

  for (Flight flight : sourceFlights) {
    float scatterX = getScatterPlotXValue(flight, dayOrder);
    if (scatterX >= minX && scatterX <= maxX) {
      matchingFlights.add(flight);
    }
  }

  return matchingFlights;
}

boolean isFlightDateInRange(String flightDateKey, String normalizedStart, String normalizedEnd) {
  if (normalizedStart.equals("") || normalizedEnd.equals("") || flightDateKey.equals("")) {
    return true;
  }

  return flightDateKey.compareTo(normalizedStart) >= 0 &&
         flightDateKey.compareTo(normalizedEnd) <= 0;
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
