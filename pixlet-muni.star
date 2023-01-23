load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("secret.star", "secret")
load("time.star", "time")

# ## CONFIG
def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "API Key",
                desc = "SFMTA API Key (511.org)",
                icon = "key",
            ),
            schema.Text(
                id = "api_key_2",
                name = "API Key 2",
                desc = "SFMTA API Key 2 (511.org)",
                icon = "key",
            )            
        ],
    )

## DATA

OUTBOUND_PREDICTIONS_URL = "https://api.511.org/transit/StopMonitoring?api_key=%s&agency=SF&stopcode=13914&format=JSON"
INBOUND_PREDICTIONS_URL = "https://api.511.org/transit/StopMonitoring?api_key=%s&agency=SF&stopcode=13915&format=JSON"

def fetch_cached(url, ttl):
    cached = cache.get(url)
    timestamp = cache.get("timestamp::%s" % url)
    if cached and timestamp:
        return json.decode(cached)
    else:
        res = http.get(url)
        if res.status_code != 200:
            print("511.org request to %s failed with status %d", (url, res.status_code))
            return (time.now().unix, {})

        # Trim off the UTF-8 byte-order mark
        body = res.body()[3:]
        data = json.decode(body)
        timestamp = time.now().unix
        cache.set(url, body, ttl_seconds = ttl)
        cache.set(("timestamp::%s" % url), str(timestamp), ttl_seconds = ttl)
        return data


def transform_data(data):
    destination_name = data["ServiceDelivery"]["StopMonitoringDelivery"]["MonitoredStopVisit"][0]["MonitoredVehicleJourney"]["DestinationName"].upper()
    expected_arrival_datetimes = [
        time.parse_time(stopvisit["MonitoredVehicleJourney"]["MonitoredCall"]["ExpectedArrivalTime"])
        for stopvisit in data["ServiceDelivery"]["StopMonitoringDelivery"]["MonitoredStopVisit"]
    ]
    expected_arrival_minutes = [
        int((dt - time.now()).minutes) for dt in expected_arrival_datetimes
    ]
    formatted_expected_arrival_times = "  ".join(["%d" % minutes for minutes in expected_arrival_minutes]) + "min"
    return {
        "destination_name": destination_name,
        "formatted_expected_arrival_times": formatted_expected_arrival_times,
    }

## UI
WHITE = "#fff"
BLACK = "#000"


def horizontal_line(color):
    return render.Box(
        width=64,
        height=1,
        color=color,
    )

def half_vertical_line(color):
    return render.Box(
        width=1,
        height=14,
        color=color,
    )

def train_logo():
    return render.Circle(
        child = render.Text("N"),
        diameter = 12,
        color = "#00539b",
    )

def transit_info_row(data):
    return render.Row(
            children = [
                half_vertical_line(BLACK),
                render.Column(children = [train_logo()]),
                half_vertical_line(BLACK),
                render.Column(
                    children = [
                        render.Row(children=[render.Marquee(child=render.Text(data["destination_name"]), width=46)]),
                        render.Row(children=[render.Text(data["formatted_expected_arrival_times"])]),
                    ]
                )
            ],
            expanded = True,
            main_align = "start",
            cross_align = "center",
        )

def main(config):
    api_key = config.str("api_key")
    api_key_2 = config.str("api_key_2")

    inbound_data = fetch_cached(INBOUND_PREDICTIONS_URL % api_key, 60)
    outbound_data = fetch_cached(OUTBOUND_PREDICTIONS_URL % api_key_2, 60)

    inbound_data = transform_data(inbound_data)
    outbound_data = transform_data(outbound_data)

    rows = [
        transit_info_row(inbound_data),
        horizontal_line(WHITE),
        transit_info_row(outbound_data),
    ]
    return render.Root(
        child = render.Column(
            children = rows,
            expanded = True,
            main_align = "start",
            cross_align = "start",
        ),
    )
