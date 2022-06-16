local utils = require "vuci.utils"
local cjson = require "cjson"

local M = {}

TMP_PATH = '/tmp/'
SERVER_LIST_PATH = "/tmp/speedtest_server_list.json"
DOWNLOAD_RESULTS_PATH = "/tmp/download_results.json"
UPLOAD_RESULTS_PATH = "/tmp/upload_results.json"
COUNTRY_SERVER_LIST_PATH = "/tmp/country_speedtest_server_list.json"
STATUS_PATH = "/tmp/status.json"

function M.get_server_list(params)
    local list = {}
    os.execute("speedtest.lua --getserverlist -q")
    local status = cjson.decode(utils.readfile(STATUS_PATH))
    if status.status == "ok" then
        list = cjson.decode(utils.readfile(SERVER_LIST_PATH))
        return { status = "ok", list =  list }
    else
        return { status = status.status, message =  status.message }
    end

end

function M.get_location(params)
    os.execute("speedtest.lua --getlocation -q")
    local status = cjson.decode(utils.readfile(STATUS_PATH))
    if status.status == "ok" then
        list = cjson.decode(utils.readfile(SERVER_LIST_PATH))
        return { status = "ok", country =  status.country }
    else
        return { status = status.status, message =  status.message }
    end	
end

function M.best_server(params)
    os.execute("speedtest.lua --bestserver " .. params.country .. " -q")
    local status = cjson.decode(utils.readfile(STATUS_PATH))
    if status.status == "ok" then
        list = cjson.decode(utils.readfile(SERVER_LIST_PATH))
        return { status = "ok", host = status.host, latency = status.latency  }
    else
        return { status = status.status, message =  status.message }
    end	
end

function M.servers_by_country(params)
    os.execute("speedtest.lua --getbycountry " .. params.country .. " -q")
    local status = cjson.decode(utils.readfile(STATUS_PATH))
    if status.status == "ok" then
        list = cjson.decode(utils.readfile(SERVER_LIST_PATH))
        return { status = "ok", host = cjson.decode(utils.readfile(COUNTRY_SERVER_LIST_PATH))  }
    else
        return { status = status.status, message =  status.message }
    end	
end

function M.do_download(params)
    local command = "speedtest.lua --download " .. params.host .. " -q"
    io.popen(command)
    return { status = "started" }
end

function M.do_upload(params)
    local command = "speedtest.lua --upload " .. params.host .. " -q"
    io.popen(command)
    return { status = "started" }
end

function M.autotest(params)
    local command = "speedtest.lua --autotest -q"
    io.popen(command)
    return { status =  "started" }
end

function M.get_download_results(params)
    local list = nil
    local file = nil

    local status = cjson.decode(utils.readfile(STATUS_PATH))
    if status.status == "error" then
        return { status = status.status, message = status.message  }
    end

    file = utils.readfile(DOWNLOAD_RESULTS_PATH)
    if file ~= nil then 
        if file ~= "" then           
            list = cjson.decode(file)
            return { status = list.status, download_speed =  list.download_speed, host = list.host }
        else
            return { status = "working", download_speed =  list.download_speed , host = list.host}
        end
    else
        return { status = "error", message = "download test unsuccessful"  }
    end
end

function M.get_upload_results(params)
    local list = nil
    local file = nil

    local status = cjson.decode(utils.readfile(STATUS_PATH))
    if status.status == "error" then
        return { status = status.status, message = status.message  }
    end

    file = utils.readfile(UPLOAD_RESULTS_PATH)
    if file ~= nil then 
        if file ~= "" then           
            list = cjson.decode(file)
            return { status = list.status, upload_speed =  list.upload_speed, host = list.host}
        else
            return { status = "working", upload_speed =  list.upload_speed, host = list.host }
        end
    else
        return { status = "error", message = "upload test unsuccessful"  }
    end
end



return M