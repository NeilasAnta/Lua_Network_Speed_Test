#!/usr/bin/env lua

local cURL = require "cURL"
local cjson = require "cjson"
local socket = require "socket"
local argparse = require "argparse"

API_IP_DATA = "https://api.myip.com"
SERVER_LIST = "https://raw.githubusercontent.com/NeilasAnta/SpeedTestServerList/main/speedtest_server_list.json"
NULL_FILE = "/dev/null"
BIG_FILE = "/dev/zero"
SERVER_LIST_LOCATION = "/tmp/speedtest_server_list.json"
COUNTRY_SERVER_LIST_LOCATION = "/tmp/country_speedtest_server_list.json"
UPLOAD_RESULT = "/tmp/upload_results.json"
DONWLOAD_RESULT = "/tmp/download_results.json"
STATUS = "/tmp/status.json"
USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36"

SIZE = 500
MAX_RETRIES = 10
TOTAL_TEST_TIME = 20

local function testServer(server)
	f = io.open(NULL_FILE, "w")
	local easy = cURL.easy()
	easy:setopt({
		url = string.format(server),
		port = 8080,
		useragent = USER_AGENT,
		timeout = 10,
		writefunction = f,
		connecttimeout = 2,
		accepttimeout_ms = 2
	})

	local status, error = pcall(function()
		easy:perform()
	end)
	if status then
		return true
	else
		return false
	end
	f:close()
	easy:close()

end

function auto_test(quiet)
	server = nil
	location = nil
	location = get_location(quiet)
	if location == 2 then
		if not quiet then
			print("Unable get location")
		end
		return 2
	end
	server = best_server(location, quiet)
	if server == 2 then
		if not quiet then
			print("Unable to determine best server")
		end
		return 2
	end
	os.remove(UPLOAD_RESULT)
	os.remove(DONWLOAD_RESULT)
	print("Download test: ")
	download(server, quiet)
	print("Upload test: ")
	upload(server, quiet)
end

function download(server, quiet)

	if server == nil then
		print("Please provide a server for download speed test using")
		return
	end

	local null_file = io.open(NULL_FILE, "w")
	local url = server .. "/download?size=" .. SIZE * 1000000
	local c = cURL.easy({
		url = url,
		port = 8080,
		httpheader = {
			"Cache-Control: no-cache"
		},
		useragent = USER_AGENT,
		writefunction = null_file,
		timeout = TOTAL_TEST_TIME,
		connecttimeout = 2,
		accepttimeout_ms = 2
	})
	local start_time = socket.gettime()
	local downloaded_size_mb, end_time, total_time, download_speed, total_size_mb, percent_downloaded, prev_size, same_value_count, download_file = 0, 0, 0, 0, 0, 0, 0, 0, 0
	print("Started")
	if not quiet then
		print(string.format("\r%-35s %-10s %-12s %-12s %-10s", "Server", "Total(MB)", "Now(MB)", "Percent(%)", "Speed, Mbps"))
	end
	if not testServer(server) then
		if not quiet then
			print("Network error")
		else
			error_message = io.open(STATUS, "w")
			error_message:write(cjson.encode({
				status = "error",
				host = server,
				message = "Network error"
			}))
			error_message:close()
		end
		return 2
	else
		ok_message = io.open(STATUS, "w")
		ok_message:write(cjson.encode({
			status = "ok",
			host = server,
			message = "started"
		}))
		ok_message:close()
	end
	c:setopt_progressfunction(function(dltotal, dlnow)
		if quiet then
			download_file = io.open(DONWLOAD_RESULT, "w")
		end
		
		if same_value_count > MAX_RETRIES then
			if quiet then
				download_file:write(cjson.encode({
					status = "error",
					host = server,
					download_speed = tostring(download_speed)
				}))
				download_file:close()
			else
				print('\nTest unsuccessful!')
			end
			c:close()
			return
		end
		downloaded_size_mb = dlnow / 1000000
		if downloaded_size_mb == prev_size then
			same_value_count = same_value_count + 1
		else
			same_value_count = 0
		end
		end_time = socket.gettime()
		total_time = end_time - start_time
		download_speed = downloaded_size_mb * 8 / total_time
		if quiet then
			download_file = io.open(DONWLOAD_RESULT, "w")
			download_file:write(cjson.encode({
				status = "working",
				host = server,
				download_speed = tostring(download_speed)
			}))
			io.close(download_file)
		end		
		if not quiet then
			total_size_mb = dltotal / 1000000
            percent_downloaded = math.floor((dlnow / dltotal * 100) * 100) / 100
			io.write(string.format("\r%-35s %-10s %-12s %-12s %-10s", server, total_size_mb, downloaded_size_mb, percent_downloaded, download_speed))
		end
		prev_size = downloaded_size_mb
		
	end)
	c:setopt(cURL.OPT_NOPROGRESS, false)
	local status, error = pcall(function()
		c:perform()
	end)
	if error == "[CURL-EASY][COULDNT_CONNECT] Error (7)" or error == "[CURL-EASY][COULDNT_RESOLVE_HOST] Error (6)" or error == "[CURL-EASY][OPERATION_TIMEDOUT] Error (28)"  then
		if not quiet then
			print("Network error")
		else
			download_file = io.open(DONWLOAD_RESULT, "w")
			download_file:write(cjson.encode({
				status = "error",
				host = server,
			}))
			download_file:close()
		end
		return 2
	end
	local json = cjson.encode({
		status = "done",
		host = server,
		download_speed = tostring(download_speed)
	})
	download_file = io.open(DONWLOAD_RESULT, "w")
	if error == "[CURL-EASY][PARTIAL_FILE] Error (18)" then
		if quiet then
			download_file:write(json)
		end
		print("\nTest finished!")
	end
	if status then
		if quiet then
			download_file:write(json)
		end
		print("\nTest finished!")
	end
	io.close(null_file)
	io.close(download_file)
end

function upload(server, quiet)
	if server == nil then
		print("Please provide a server for upload speed test using")
		return
	end
	local null_file = io.open(NULL_FILE, "w")
	local url = server .. "/upload"
	local c = cURL.easy({
		url = url,
		port = 8080,
		useragent = USER_AGENT,
		post = true,
		httpheader = {
			"Cache-Control: no-cache"
		},
		httppost = cURL.form({
			file0 = {
				file = BIG_FILE,
				type = "text/plain",
				name = "upload1.lua"
			}
		}),
		timeout = TOTAL_TEST_TIME,
		connecttimeout = 2,
		accepttimeout_ms = 2
	})
	local start_time = socket.gettime()
	local uploaded_size_mb, end_time, total_time, upload_speed, total_size_mb, percent_uploaded, prev_size, same_value_count, upload_file = 0, 0, 0, 0, 0, 0, 0, 0, 0
	print("Started")	
	if not quiet then
		print(string.format("\r%-35s %-12s %-10s", "Server", "Now(MB)", "Speed, Mbps"))
	end
	if not testServer(server) then
		if not quiet then
			print("Network error")
		else
			error_message = io.open(STATUS, "w")
			error_message:write(cjson.encode({
				status = "error",
				host = server,
				message = "Network error"
			}))
			error_message:close()
		end
		return 2
	else
		ok_message = io.open(STATUS, "w")
		ok_message:write(cjson.encode({
			status = "ok",
			host = server,
			message = "started"
		}))
		ok_message:close()
	end
	c:setopt_progressfunction(function(_, _, ultotal, ulnow)
		if quiet then
			upload_file = io.open(UPLOAD_RESULT, "w")
		end

		if same_value_count > MAX_RETRIES then
			if quiet then
				upload_file:write(cjson.encode({
					status = "error",
					upload_speed = tostring(upload_speed)
				}))
				upload_file:close()
			else
				print('\nTest unsuccessful!')
			end
			c:close()
			return
		end
		uploaded_size_mb = ulnow / 1000000
		if uploaded_size_mb == prev_size then
			same_value_count = same_value_count + 1
		else
			same_value_count = 0
		end
		end_time = socket.gettime()
        total_time = end_time - start_time
		upload_speed = uploaded_size_mb * 8 / total_time
		if quiet then
			upload_file:write(cjson.encode({
				status = "working",
				host = server,
				upload_speed = tostring(upload_speed)
			}))
			io.close(upload_file)
		end
		if not quiet then
			io.write(string.format("\r%-35s %-12s %-10s", server, uploaded_size_mb, upload_speed))
		end
		prev_size = uploaded_size_mb
	end)
	
	c:setopt(cURL.OPT_NOPROGRESS, false)
	local status, error = pcall(function()
		c:perform()
	end)

	if error == "[CURL-EASY][COULDNT_CONNECT] Error (7)" or error == "[CURL-EASY][COULDNT_RESOLVE_HOST] Error (6)" then
		if not quiet then
			print("Network error")
		else
			upload_file = io.open(UPLOAD_RESULT, "w")
			upload_file:write(cjson.encode({
				status = "error",
				host = server
			}))
			upload_file:close()
		end
		return 2
	end

	local json = cjson.encode({
		status = "done",
		host = server,
		upload_speed = tostring(upload_speed)
	})
	upload_file = io.open(UPLOAD_RESULT, "w")
	if error == "[CURL-EASY][OPERATION_TIMEDOUT] Error (28)" then
		if quiet then
			upload_file:write(json)
		end
		print("\nTest finished!")
		return
	end

	if status then
		if quiet then
			upload_file:write(json)
		end
		print("\nTest finished!")
	end
	io.close(null_file)
	io.close(upload_file)
end


function get_serverlist(quiet)
	f = io.open(SERVER_LIST_LOCATION, "w")
	local c = cURL.easy({
		url = SERVER_LIST,
		writefunction = f,
		useragent = USER_AGENT,
		timeout = 10,
		connecttimeout = 2,
		accepttimeout_ms = 2
	})
	local status, error = pcall(function()
		c:perform()
	end)

	if error == "[CURL-EASY][COULDNT_CONNECT] Error (7)" or error == "[CURL-EASY][COULDNT_RESOLVE_HOST] Error (6)" or error == "[CURL-EASY][OPERATION_TIMEDOUT] Error (28)" then
		os.remove(SERVER_LIST_LOCATION)
		if not quiet then 
			print("Couldnt connect to network")
		else
			status_file = io.open(STATUS, "w")
			status_file:write(cjson.encode({
				status = "error",
				message = "Couldnt connect to network"
			}))
			status_file:close()
		end
		f:close()
		return 2
	end
	if not quiet then
		print("Done")
	else
		status_file = io.open(STATUS, "w")
		status_file:write(cjson.encode({
			status = "ok",
			message = "done"
		}))
		status_file:close()
	end
	f:close()
end


function best_server(countryName, quiet)
	if not file_exists(SERVER_LIST_LOCATION) then
		get_serverlist()
	end
	serverList = io.open(SERVER_LIST_LOCATION, "r")
	local jsonString = serverList:read("*a")
	local parsedValues = cjson.decode(jsonString)
	local minTime = 999999999
	local serverTime = 999999999
	local serverData = nil
	f = io.open("/dev/null", "w")
	for i, line in ipairs(parsedValues) do
		if line.country == countryName then
			local easy = cURL.easy()
			easy:setopt({
				url = string.format(line.host),
				port = 8080,
				useragent = USER_AGENT,
				writefunction = f,
				timeout = 10,
				connecttimeout = 2,
				accepttimeout_ms = 2
			})
			local status, error = pcall(function()
				easy:perform()
			end)
			if status then
				easy:getinfo_response_code()
				serverTime = easy:getinfo_total_time()
				if minTime > serverTime then
					minTime = serverTime
					serverData = line
				end
			end
			easy:close()
		end
	end

	if serverData == nil then
		if not quiet then
			print("Server not found")
		else
			status_file = io.open(STATUS, "w")
			status_file:write(cjson.encode({
				status = "error",
				message = "Server not found"
			}))
			io.close(status_file)
		end
		return 2
	else
		if not quiet then
			print(serverData['host'])
			print("Latency: " .. minTime)
		else
			status_file = io.open(STATUS, "w")
			status_file:write(cjson.encode({
				status = "ok",
				host = serverData['host'],
				latency = minTime
			}))
			io.close(status_file)
		end
		return serverData['host']
	end
	
end

function get_by_country(countryName, quiet)
	os.remove(COUNTRY_SERVER_LIST_LOCATION)
	if not file_exists(SERVER_LIST_LOCATION) then
		if get_serverlist(quiet) == 2 then
			return 2
		end
	end
	serverList = io.open(SERVER_LIST_LOCATION, "r")
	local jsonString = serverList:read("*a")
	local parsedValues = cjson.decode(jsonString)
	local serverData = {}
	for i, line in ipairs(parsedValues) do
		if line.country == countryName then
			table.insert(serverData, line)
			if not quiet then
				print(cjson.decode(line))
			end
		end
	end
	f = io.open(COUNTRY_SERVER_LIST_LOCATION, "w")
	if next(serverData) == nil then
		os.remove(COUNTRY_SERVER_LIST_LOCATION)
		if not quiet then
			print("Not found servers by country")
		else
			status_file = io.open(STATUS, "w")
			status_file:write(cjson.encode({
				status = "error",
				message = "Not found servers by country",
			}))
			io.close(status_file)			
		end
		f:close()
		return 2
	end
	if quiet then
		f:write(cjson.encode(serverData))
		f:close()
		status_file = io.open(STATUS, "w")
		status_file:write(cjson.encode({
			status = "ok",
			message = "Done",
		}))
		io.close(status_file)	
		print("Done")
	end
	serverList:close()
end

function get_location(quiet)
	local easy = cURL.easy()
	local data = {}
	local parsed = nil
	easy:setopt({
		url = string.format(API_IP_DATA),
		timeout = 10,
		connecttimeout = 5,
		accepttimeout_ms = 5
	})
	easy:setopt_writefunction(table.insert, data)
	local status, error = pcall(function()
		easy:perform()
	end)

	if error == "[CURL-EASY][COULDNT_CONNECT] Error (7)" or error == "[CURL-EASY][COULDNT_RESOLVE_HOST] Error (6)" or error == "[CURL-EASY][OPERATION_TIMEDOUT] Error (28)" then
		if not quiet then
			print("Couldnt connect to network")
		end
			status_file = io.open(STATUS, "w")
			status_file:write(cjson.encode({
				status = "error",
				message = "Couldnt connect to network",
			}))
			status_file:close()
		return 2
	end 

	if status then
		easy:getinfo_response_code()
		table.concat(data)
	end
	easy:close()
	parsed = cjson.decode(data[1])
	if not quiet then
		print(parsed.country)
	else
		print("Done")
		status_file = io.open(STATUS, "w")
		status_file:write(cjson.encode({
			status = "ok",
			country = parsed.country,
		}))
		status_file:close()
	end
	
	return parsed.country
end

function file_exists(name)
	local a = io.open(name, "r")
	if a ~= nil then
		io.close(a)
		return true
	else
		return false
	end
end


local parser = argparse()
parser:option("-D --download", "Download"):argname("<host>")
parser:option("-U --upload", "Upload"):argname("<host>")
parser:option("--bestserver", "Find best server to test upload or downbload"):argname("<country>")
parser:option("--getbycountry", "Put server list in json type file in /tmp/country_server_list.json"):argname("<country>")
parser:flag("--getlocation", "Find location by IP")
parser:flag("--autotest", "Auto Test")
parser:flag("--getserverlist", "Put server list in json type file in /tmp/speedtest_server_list.json")
parser:flag("-q --quiet", "Flag to print to file")
local args = parser:parse()

if args['download'] ~= nil then
	download(args['download'], args['quiet'])
elseif args['upload'] ~= nil then
	upload(args['upload'], args['quiet'])
elseif args['bestserver'] ~= nil then
	best_server(args['bestserver'], args['quiet'])
elseif args['getlocation'] == true then
	get_location(args['quiet'])
elseif args['getserverlist'] == true then
	get_serverlist(args['quiet'])
elseif args['autotest'] == true then
	auto_test(args['quiet'])
elseif args['getbycountry'] ~= nil then
	get_by_country(args['getbycountry'], args['quiet'])
elseif next(args) == nil then
	print(parser:get_usage())
end