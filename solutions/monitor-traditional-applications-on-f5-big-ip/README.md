# Monitoring Traditional Applications on F5 BIG-IP

## Solution Description
Customers may find it cumbersome, time-consuming, and costly to proactively ensure that their mission-critical workloads operate in an optimized manner.
This proves challenging to ensure a consistently high-quality user experience (UX) to ensure customer stickiness and repeatable business.
To address these challenges, this solution demonstrates how to configure F5 BIG-IP using the Telemetry Streaming and Application Services extensions to send traffic metrics to an Open Telemetry Collector.
For the demo, we have our [Open Telemetry Collector](https://github.com/open-telemetry/opentelemetry-collector-contrib) configured to forward data to a [Grafana LGTM](https://grafana.com/) stack, but any monitoring solution compatible with Open Telemetry should work.

<img src="images/architecture.png" height="50%" width="50%">

## Value
Specifically, this solution solves the following use case:
```gherkin
Given a running instance of F5 BIG-IP
    And an application is load balanced by that instance of F5 BIG-IP
    And a third party monitoring solution
When the application's traffic patterns change
Then the changes can be visualized in the third party monitoring solution
```

## Demo
Demo publication is in progress, please check back later.
<!--[![Video](https://img.youtube.com/vi/2fRqVYpZOK4/maxresdefault.jpg)](https://www.youtube.com/watch?v=2fRqVYpZOK4&t=519s)-->

## Automation to Deploy Solution
1. Install [Telemetry Streaming extension](https://github.com/F5Networks/f5-telemetry-streaming).
2. Install [Application Services extension](https://github.com/F5Networks/f5-appsvcs-extension).
3. Edit `open-telemetry.ts.json` with information on how to connect to your Open Telemetry Collector.
4. Send a POST request to the `mgmt/shared/telemetry/declare` endpoint with `open-telemetry.ts.json` as the payload.
5. Send a POST request to the `mgmt/shared/appsvcs/declare` endpoint with `common.as3.json` as the payload.
6. Edit  `demo.as3.json` to match the needs of your application.
7. Send a POST request to the `mgmt/shared/appsvcs/declare` endpoint with `demo.as3.json` as the payload.

## Deep Dive
### Telemetry Streaming Configuration
We need to configure three components in Telemetry Streaming to get the data we want to an Open Telemetry Collector.
In the following sections we will explore how to configure each of these components.
You can find the full Telemetry Streaming declaration in this repository as [open-telemetry.ts.json](open-telemetry.ts.json).

#### System Poller
```json
{
  "class": "Telemetry_System_Poller",
  "interval": 10,
  "endpointList": [
    {
      "protocol": "http",
      "path": "mgmt/tm/ltm/profile/http/stats?$select=resp_2xxCnt,resp_4xxCnt,resp_5xxCnt,tmName",
      "name": "responseCodes"
    }
  ]
}
```
Here we have a `Telemetry_System_Poller` class configured with custom endpoints to gather response status codes.
We use custom endpoints here to filter the gathered data down to what we need.
This allows Telemetry Streaming to do less work and reduce its impact on the BIG-IP system.
With reduced impact on the system, we can use a more aggressive query interval of 10 seconds.
Custom endpoints can gather any data available through the [iControlREST](https://clouddocs.f5.com/api/icontrol-rest/) API.
If you would rather use SNMP, Telemetry Streaming can now [query SNMP endpoints](https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/declarations.html#querying-snmp-using-a-custom-endpoint).
You can find more information on the endpoints that Telemetry Streaming gathers by default [here](https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/poller-default-output-reference.html).

#### Listener
```json
{
  "class": "Telemetry_Listener",
  "port": 6514
}
```
The `Telemetry_Listener` class requires little configuration in the declaration.
We will need to do more work later to configure the BIG-IP to send data to the Telemetry Streaming listener.
For now, we just tell Telemetry Streaming to listen for data coming in on port 6514.

#### Consumer
```json
{
  "class": "Telemetry_Consumer",
  "type": "OpenTelemetry_Exporter",
  "host": "monitor.example.com",
  "metricsPath": "/v1/metrics",
  "port": 80,
  "protocol": "http",
  "exporter": "json"
}
```
Now that we have configured Telemetry Streaming to gather data, we need to configure a `Telemetry_Consumer` class to send that data to our third party monitoring tool.
For this example, Telemetry Streaming sends data to an Open Telemetry Collector over HTTP.
You can find a list of available Telemetry Streaming consumers [here](https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/).
Open Telemetry Collector supports output [a wide variety of formats](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter).

### Application Services Common Configuration
Before we can configure per-application telemetry, we need to setup some shared components.
These shared components send data to Telemetry Streaming's Event Listener.
For this, we will use the Application Services extension, commonly referred to as AS3.
You can find the full AS3 declaration in this repository as [common.as3.json](common.as3.json).

#### Configuring Telemetry Streaming Log Publisher
First, let us look at configuring a BIG-IP Log Publisher component to forward data to Telemetry Streaming's Event Listener.
We need to use intermediate BIG-IP components to form a chain passing the data from one component to the next until it ultimately ends up reaching Telemetry Streaming.
Now for some good news.
AS3 can configure these components for us.
The following diagram visualizes this chain of components and the AS3 configuration for each component.

<img src="images/publisherChain.png" height="100%" width="100%">

We have deviated from the configuration presented in the Telemetry Streaming documentation.
To send data from an iRule, **we need a Log Destination with no formatting** instead of the Splunk formatting used in the Telemetry Streaming documentation.

#### Sending Data to Telemetry Streaming via iRule
No BIG-IP article would be complete without an iRule.
Here we use one to gather HTTP response times and send them via high speed logging (HSL) to the Log Publisher we set up before.
Pay careful attention to the formatting of the data.
As an advanced use case, Telemetry Streaming expects this custom data to be in a particular format.
* Present Key value pairs as a comma separated list
* Do not use quotation marks for key names
* Use quotation marks for values
* Avoid any spaces in this string

The iRule can optionally collect data by country code.
This allows a user to monitor data by region to inform resource distribution decisions.
The following code sample contains the full iRule used for this example.
We use base64 encoding in the AS3 declaration to make it easier to embed in the JSON payload.
Following this pattern, you can create iRules that can gather a wide variety of traffic data.

```tcl
when RULE_INIT {
    set static::metric_table_name traffic_data
    set static::publisher "/Common/Shared/telemetry_publisher"

    # Shortest interval (in seconds) to log a message
    set static::min_log_interval 10
    set static::last_log_key "last_log_timestamp"

    set static::enable_geoip_data 1
    set static::invalid_country_code "ZZ"
}
when HTTP_RESPONSE {
    set key "[virtual]"

    # Gather location data
    if {[expr {$static::enable_geoip_data == 1}]} {
        set ipaddr [IP::client_addr]
        set country [whereis $ipaddr country]
        if {[expr {$country eq ""}]} {
            set country $static::invalid_country_code
        }
        set key "$key:$country"
    }

    table append -subtable $static::metric_table_name $key " [expr {[TCP::rtt] / 32.0}]";

    set lastlog [table lookup $static::last_log_key]
    set now [clock seconds]
    if { $lastlog equals "" } {
        # This is the first execution so create the table entry and force a log attempt
        table add $static::last_log_key $now
        set lastlog 0
    }

    # Only send data on a defined interval
    if {[expr { ($now - $lastlog) > $static::min_log_interval }]} {
        # Open a connection to a Publisher
        set hsl [HSL::open -publisher $static::publisher]
        # Iterate through each application
        foreach key [table keys -subtable $static::metric_table_name] {

            set key_parts [split $key :]
            set application [lindex $key_parts 0]
            set country [lindex $key_parts 1]

            set values [table lookup -subtable $static::metric_table_name $key]
            # Gather response time metrics
            set max 0
            set min indef
            set total 0.0
            set count 0
            foreach value $values {
                if {[expr {$value > $max}]}{
                    set max $value
                }
                if {[expr {$value < $min}]}{
                    set min $value
                }
                set total [expr {$total + $value}]
                incr count 1
            }

            if {[expr {$count == 0}]} {
                continue
            }

            set avg [expr {$total / $count}]

            # Prepare data in JSON format
            set data application=\"$application\",rttTimeMin=\"$min\",rttTimeMax=\"$max\",rttTimeAvg=\"$avg\"
            if {[expr {$static::enable_geoip_data == 1}]} {
                set data "$data,country=\"$country\""
            }

            # Send data to a Publisher
            set send_result [HSL::send ${hsl} "${data}"]
            if {[expr {$send_result == 0}]} {
                log local0. "Failed to send data to $static::publisher, please ensure that it is not using a formatted destination."
            }
        }
        table replace $static::last_log_key $now
        table delete -subtable $static::metric_table_name -all
    }
}
```

### AS3 Per-Application Configuration
The AS3 declaration used for the application is the [basic HTTP example](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/getting-started.html#simple-http-application) with two modifications.
First, we attach the iRule from the Common declaration to capture traffic data.
Second, we have a custom HTTP Profile.
Using a unique HTTP Profile for each application allows us to identify the HTTP Profile stats as belonging to this application.
You can find the full AS3 declaration in the following code block and in this repository as [demo.as3.json](`demo.as3.json`).

```json:demo.as3.json
{
  "class": "ADC",
  "schemaVersion": "3.0.0",
  "AATT": {
    "class": "Tenant",
    "astroshop.example.com": {
      "class": "Application",
      "astroshop.example.com": {
        "class": "Service_HTTP",
        "virtualAddresses": [
          "10.192.125.162"
        ],
        "profileHTTP": { "use": "httpProfile" },
        "pool": "pool",
        "iRules": [
          { "use": "/Common/Shared/appTelemetryIRule" }
        ]
      },
      "httpProfile": {
        "class": "HTTP_Profile"
      },
      "pool": {
        "class": "Pool",
        "monitors": [
          "icmp",
          "http"
        ],
        "members": [
          {
            "servicePort": 80,
            "serverAddresses": [
              "10.192.125.164"
            ]
          }
        ]
      }
    }
  }
}
```
