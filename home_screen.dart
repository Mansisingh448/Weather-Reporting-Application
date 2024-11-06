import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_weather_app/api.dart';
import 'package:flutter_weather_app/forecastmodel.dart';
import 'package:flutter_weather_app/weathermodel.dart';
import 'package:intl/intl.dart';
import 'package:flutter_weather_app/apihour.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController locCtrl = TextEditingController();

  ApiResponse? response;
  ApiResponse1? response1;
  bool inProgress = false;

  Future<ApiResponse?> fetchCurrentWeather(String location) async {
    try {
      return await WeatherApi().getCurrentWeather(location);
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }

  Future<ApiResponse1?> fetchHourlyWeather(String location) async {
    try {
      return await WeatherHourlyApi().getHourlyWeather(location);
    } catch (e) {
      print('Error fetching hourly weather data: $e');
      return null;
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _buildSearchWidget(),
                  const SizedBox(
                    height: 20,
                  ),
                  if (inProgress)
                    const CircularProgressIndicator()
                  else if (response != null && response1 != null)
                    Expanded(
                      child: ListView(
                        children: [
                          temperatureAreaWidget(),
                          const SizedBox(height: 10),
                          forecastWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          const Center(
                            child: Text(
                              'Next-Days',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          dailyforecastWidget(),
                        ],
                      ),
                    )
                  else
                    const Text('No data available')
                ]))));
  }

  Widget _buildSearchWidget() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: locCtrl,
        onSubmitted: (value) {
          setState(() {
            inProgress = true;
          });
          Future.wait([
            fetchCurrentWeather(value),
            fetchHourlyWeather(value),
          ]).then((results) {
            setState(() {
              response = results[0] as ApiResponse?;
              response1 = results[1] as ApiResponse1?;
              inProgress = false;
            });
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search any location',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget temperatureAreaWidget() {
    if (response?.weather == null || response!.weather!.isEmpty) {
      return const Text('No weather data available');
    }

    DateTime date = DateTime.fromMillisecondsSinceEpoch(response!.dt! * 1000);
    String formattedDate = DateFormat('yyyy/MMM/dd').format(date);

    double tempInCelsius = response!.main!.temp! - 273.15;
    double windSpeedKmh = response!.wind!.speed! * 3.6;
    double feelsLikeincelsius = response!.main!.feelsLike! - 273.15;
    double visibiltyInKm = response!.visibility! / 1000;

    DateTime sunrise =
        DateTime.fromMillisecondsSinceEpoch(response!.sys!.sunrise! * 1000);
    DateTime sunset =
        DateTime.fromMillisecondsSinceEpoch(response!.sys!.sunset! * 1000);

    String formattedSunrise = DateFormat('hh:mm a').format(sunrise);
    String formattedSunset = DateFormat('hh:mm a').format(sunset);

    return Expanded(
      child: ListView.builder(
          itemCount: response!.weather!.length,
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            var weather = response!.weather![index];
            String url = "${weather.icon}.png";

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_sharp,
                              size: 45,
                              color: Color.fromARGB(255, 3, 47, 123),
                            ),
                            Text(response?.name ?? '',
                                style: const TextStyle(
                                    fontSize: 40,
                                    color: Color.fromARGB(255, 3, 47, 123),
                                    fontWeight: FontWeight.bold)),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (response!.weather != null &&
                              response!.weather!.isNotEmpty)
                            Image.asset(
                              "assets/weather/$url",
                              height: 100,
                              width: 100,
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.thermostat,
                                size: 35,
                                color: Color.fromARGB(255, 3, 47, 123),
                              ),
                              Text(
                                "${tempInCelsius.toStringAsFixed(1)}°C",
                                style: const TextStyle(
                                    fontSize: 30,
                                    color: Color.fromARGB(255, 3, 47, 123),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Card(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            weather.main ?? '',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            weather.description ?? '',
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/humidity.png",
                              height: 40,
                              width: 40,
                            ),
                            const Text("Humidity"),
                            Text('${response?.main?.humidity ?? ''}%')
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/windspeed.png",
                              height: 40,
                              width: 40,
                            ),
                            const Text("Windspeed"),
                            Text('${windSpeedKmh.toStringAsFixed(1)}km/h')
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/clouds.png",
                              height: 40,
                              width: 40,
                            ),
                            const Text("Clouds"),
                            Text('${response?.clouds?.all}%')
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/pressure.png",
                              height: 40,
                              width: 40,
                            ),
                            const Text("Pressure"),
                            Text('${response?.main?.pressure ?? ''}mBar')
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/feelslike.png",
                              height: 40,
                              width: 40,
                            ),
                            const Text("Feels_like"),
                            Text("${feelsLikeincelsius.toStringAsFixed(1)}°C")
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          children: [
                            Image.asset(
                              "assets/icons/visibility.png",
                              height: 40,
                              width: 40,
                            ),
                            const Text("Visibility"),
                            Text('${visibiltyInKm.toStringAsFixed(1)}km')
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Image.asset(
                                "assets/sun/sunrise.png",
                                height: 50,
                                width: 50,
                              ),
                              const Text("Sunrise"),
                              Text(
                                formattedSunrise,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Image.asset(
                                "assets/sun/sunset.png",
                                height: 50,
                                width: 50,
                              ),
                              const Text("Sunset"),
                              Text(
                                formattedSunset,
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Today',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ]),
                ]);
          }),
    );
  }

  Widget forecastWidget() {
    if (response1?.list == null || response1!.list!.isEmpty) {
      return const Text('No forecast data available');
    }

    var now = DateTime.now();
    var todayForecasts = response1!.list!.where((forecast) {
      var date = DateTime.fromMillisecondsSinceEpoch(forecast.dt! * 1000);
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: todayForecasts.length,
          itemBuilder: (context, index) {
            var forecast = todayForecasts[index];

            String url1 = "${forecast.weather?[0].icon}.png";

            var date = DateTime.fromMillisecondsSinceEpoch(forecast.dt! * 1000);
            var formattedTime = DateFormat('hh:mm a').format(date);
            var tempInCelsius = forecast.main!.temp! - 273.15;
            var feelsLikeInCelsius = forecast.main!.feelsLike! - 273.15;

            return Card(
              elevation: 5,
              shadowColor: Colors.blueGrey,
              child: SizedBox(
                height: 150,
                width: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(formattedTime,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    if (response1!.list != null && response1!.list!.isNotEmpty)
                      Image.asset(
                        "assets/weather/$url1",
                        height: 60,
                        width: 60,
                      ),
                    Text(forecast.weather?[0].main ?? ''),
                    Text(
                      "${tempInCelsius.toStringAsFixed(1)}°C",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        children: [
                          const Text("Feels_Like:"),
                          Text(
                            " ${feelsLikeInCelsius.toStringAsFixed(1)}°C",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget dailyforecastWidget() {
    if (response1?.list == null || response1!.list!.isEmpty) {
      return const Text('No forecast data available');
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: response1!.list!.length,
        itemBuilder: (context, index) {
          var forecast = response1!.list![index];
          var date = DateTime.fromMillisecondsSinceEpoch(forecast.dt! * 1000);
          var formattedDate = DateFormat('EEE, MMM dd').format(date);

          String url1 = "assets/weather/${forecast.weather?[0].icon}.png";
          var tempInCelsius = forecast.main!.temp! - 273.15;
          var feelsLikeInCelsius = forecast.main!.feelsLike! - 273.15;
          double windSpeedKmh = forecast.wind!.speed! * 3.6;
          double visibiltyInKm = forecast.visibility! / 1000;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Card(
                elevation: 5,
                shadowColor: Colors.blueGrey,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        url1,
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '${forecast.weather?.isNotEmpty == true ? forecast.weather![0].main : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${tempInCelsius.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(children: [
                            const Text("Feels_like:"),
                            Text(
                              '${feelsLikeInCelsius.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ]),
                        ],
                      ),
                      Card(
                          elevation: 5,
                          shadowColor: Colors.blueGrey,
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "assets/icons/windspeed.png",
                                    height: 20,
                                    width: 20,
                                  ),
                                  Text(
                                      '${windSpeedKmh.toStringAsFixed(1)}km/h'),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Image.asset(
                                    "assets/icons/visibility.png",
                                    height: 25,
                                    width: 25,
                                  ),
                                  Text('${visibiltyInKm.toStringAsFixed(1)}km'),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Image.asset(
                                    "assets/icons/humidity.png",
                                    height: 25,
                                    width: 25,
                                  ),
                                  Text('${forecast.main!.humidity ?? ''}%'),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Image.asset(
                                    "assets/icons/clouds.png",
                                    height: 25,
                                    width: 25,
                                  ),
                                  Text('${forecast.clouds?.all}%'),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Image.asset(
                                    "assets/icons/pressure.png",
                                    height: 28,
                                    width: 28,
                                  ),
                                  Text('${forecast.main?.pressure}mBar')
                                ]),
                          )),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}
