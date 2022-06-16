## Speed Test

Documentation for SpeedTest API/RPC.

## <a name="api"></a>API-RPC methods

## <a name="login">Login

Login to get sid ID to do other requests


```no-highlight
Post 192.168.1.1/rpc
```


#### Body parameters JSON

| Name     | Type   |
| -------- | ------ |
| username | string |
| password | string |


```json
{
    jsonrpc": "2.0",
    "id": 134,
    "method": "login",
    "params": {"username": "admin", "password": "Admin123"}
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "sid": "326da59c4048ad36789d6f86ddbdc545",
        "username": "admin"
    }
}
```

## <a name="best-server">Find best server to test

```no-highlight
Post 192.168.1.1:/rpc
```

#### Body parameters

| Name      | Type   |
| --------- | ------ |
| SID       | string |
| COUNTRY   | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "best_server", {"country": "COUNTRY"}]
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "ok",
        "host": "speed-kaunas.telia.lt:8080",
        "latency": 0.005509
    }
}
```

## <a name="location">Get Location

```no-highlight
Post 192.168.1.1:/rpc
```

#### Body parameters

| Name      | Type   |
| --------- | ------ |
| SID       | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "get_location"]
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "ok",
        "country": "Lithuania"
    }
}
```

## <a name="get-server-list">Get Server List

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "get_server_list"]}
```

#### Response
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "ok",
        "list": [
            {
                "host": "speedtest.a-mobile.biz:8080",
                "city": "Sukhum",
                "country": "Abkhaziya",
                "provider": "A-Mobile",
                "id": 9714
            },
            {
                "host": "hrtspeedtest.afghan-wireless.com:8080",
                "city": "Herat",
                "country": "Afghanistan",
                "provider": "Afghan Wireless",
                "id": 9622
            },
            {
                "host": "durres.albtelecom.al:8080",
                "city": "Durres",
                "country": "Albania",
                "provider": "Albtelecom sh.a",
                "id": 2435
            }
        ]
    }
}
```




## <a name="get-server-list-by-country">Get Server List By Country

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |
| COUNTRY   | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "servers_by_country", "get_server_list", , {"country": "COUNTRY"}]
}
```

#### Response
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "ok",
        "host": [
            {
                "host": "speedtest.litnet.lt:8080",
                "city": "Kaunas",
                "country": "Lithuania",
                "provider": "Litnet",
                "id": 16248
            },
            {
                "host": "speed-kaunas.telia.lt:8080",
                "city": "Kaunas",
                "country": "Lithuania",
                "provider": "Telia",
                "id": 16249
            },
            {
                "host": "speedtest.kis.lt:8080",
                "city": "Kaunas",
                "country": "Lithuania",
                "provider": "UAB Kauno interneto sistemos",
                "id": 18415
            },
            {
                "host": "sp1.kli.lt:8080",
                "city": "Mazeikiai",
                "country": "Lithuania",
                "provider": "KLI LT, UAB",
                "id": 12638
            },
            {
                "host": "stnet1.balticum.lt:8080",
                "city": "Klaipeda",
                "country": "Lithuania",
                "provider": "Balticum TV",
                "id": 3556
            },
            {
                "host": "speedtest.bacloud.com:8080",
                "city": "Siauliai",
                "country": "Lithuania",
                "provider": "www.bacloud.com",
                "id": 10420
            },
            {
                "host": "speedtest1.ntt.lt:8080",
                "city": "Vilnius",
                "country": "Lithuania",
                "provider": "Nacionalinis telekomunikacijÃƒâ€¦Ã‚Â³ tinklas",
                "id": 11789
            },
            {
                "host": "speedtest-vno.init.lt:8080",
                "city": "Vilnius",
                "country": "Lithuania",
                "provider": "INIT",
                "id": 18277
            },
            {
                "host": "speedtest.rackray.eu:8080",
                "city": "Vilnius",
                "country": "Lithuania",
                "provider": "Rackray",
                "id": 9100
            },
            {
                "host": "speedtest.bite.lt:8080",
                "city": "Vilnius",
                "country": "Lithuania",
                "provider": "Bite Lietuva",
                "id": 7579
            },
            {
                "host": "vln038-speedtest-1.tele2.net:8080",
                "city": "Vilnius",
                "country": "Lithuania",
                "provider": "Tele2",
                "id": 6083
            },
            {
                "host": "speedtest-01.cgates.lt:8080",
                "city": "Vilnius",
                "country": "Lithuania",
                "provider": "UAB Cgates",
                "id": 3058
            }
        ]
    }
}
```



## <a name="do-download">Do Download

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |
| HOST      | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "do_download", {"host": "HOST"}]}
```

#### Response
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "started"
    }
}
```



## <a name="do-upload">Do Upload

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |
| HOST      | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "do_upload", {"host": "HOST"}]}
```

#### Response
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "started"
    }
}
```

## <a name="do-auto-test">Do Auto Test

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "autotest"]}
```

#### Response
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "started"
    }
}
```



## <a name="download-result">Get Download Result

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "get_download_results"]
}
```

#### Response
##### Response when done
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "done",
        "download_speed": "145.29690443915",
        "host": "speedtest.kis.lt:8080"
    }
}
```

##### Response when working
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "working",
        "download_speed": "137.29690443915",
        "host": "speedtest.kis.lt:8080"
    }
}
```

##### Response when error(message may be different by error)
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "error",
        "message": "Network error"
    }
}
```


## <a name="download-result">Get Download Result

```no-highlight
Post 192.168.1.1:/rpc
```
#### Body parameters


| Name      | Type   |
| --------- | ------ |
| SID       | string |


```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "method": "call",
    "params": ["SID", "speed", "get_upload_results"]
}
```

#### Response
##### Response when done
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "done",
        "upload_speed": "485.29690443915",
        "host": "speedtest.kis.lt:8080"
    }
}
```

##### Response when working
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "working",
        "upload_speed": "354.29690443915",
        "host": "speedtest.kis.lt:8080"
    }
}
```

##### Response when error(message may be different by error)
```json
{
    "jsonrpc": "2.0",
    "id": 134,
    "result": {
        "status": "error",
        "message": "Network error"
    }
}
```

