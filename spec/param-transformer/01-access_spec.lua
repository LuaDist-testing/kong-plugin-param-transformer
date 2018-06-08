local helpers = require "spec.helpers"
local cjson = require "cjson"

describe("Plugin: param-transformer (access)", function()
  local client

  setup(function()
    local api1 = assert(helpers.dao.apis:insert { 
        name = "api-1", 
        uris = { [[/a/(?<p1>\S+)/b/(?<p2>\S+)]] }, 
        upstream_url = "http://mockbin.com/request/{{p1}}/{{p2}}?p1={{p1}}",
    })

    assert(helpers.dao.plugins:insert {
      api_id = api1.id,
      name = "param-transformer",
    })

    local api2 = assert(helpers.dao.apis:insert { 
      name = "api-2", 
      uris = { [[/a2/(?<p1>\S+)/b/(?<p2>\S+)]] }, 
      upstream_url = "http://mockbin.com/request/{{p1}}/{{p1}}",
    })

    assert(helpers.dao.plugins:insert {
      api_id = api2.id,
      name = "param-transformer",
    })

    -- start kong, while setting the config item `custom_plugins` to make sure our
    -- plugin gets loaded
    assert(helpers.start_kong {custom_plugins = "param-transformer"})
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  before_each(function()
    client = helpers.proxy_client()
  end)

  after_each(function()
    if client then client:close() end
  end)

  describe("request", function()
    it("regx1", function()
      local r = assert(client:send {
        method = "GET",
        path = "/a/123/b/456",
      })
      assert.response(r).has.status(200)
      local json = assert.response(r).has.jsonbody()
      local url = assert(json["url"])
      local host = assert(json["headers"]["host"])
      assert.equal("http://0.0.0.0/request/123/456", url)
      assert.equal("mockbin.com", host)
    end)

    it("regx2", function()
      local r = assert(client:send {
        method = "GET",
        path = "/a/12-3/b/4+56",
      })
      assert.response(r).has.status(200)
      local json = assert.response(r).has.jsonbody()
      local url = assert(json["url"])
      local host = assert(json["headers"]["host"])
      assert.equal("http://0.0.0.0/request/12-3/4+56", url)
      assert.equal("mockbin.com", host)
    end)

    it("regx3", function()
      local r = assert(client:send {
        method = "GET",
        path = "/a/123-*/b/456",
      })
      assert.response(r).has.status(200)
      local json = assert.response(r).has.jsonbody()
      local url = assert(json["url"])
      local host = assert(json["headers"]["host"])
      assert.equal("http://0.0.0.0/request/123-*/456", url)
      assert.equal("mockbin.com", host)
    end)

    it("regx4", function()
      local r = assert(client:send {
        method = "GET",
        path = "/a/12()3/b/456",
      })
      assert.response(r).has.status(200)
      local json = assert.response(r).has.jsonbody()
      local url = assert(json["url"])
      local host = assert(json["headers"]["host"])
      assert.equal("http://0.0.0.0/request/12()3/456", url)
      assert.equal("mockbin.com", host)
    end)
    
    it("regx5", function()
      local r = assert(client:send {
        method = "GET",
        path = "/a2/123/b/456",
      })
      assert.response(r).has.status(200)
      local json = assert.response(r).has.jsonbody()
      local url = assert(json["url"])
      local host = assert(json["headers"]["host"])
      assert.equal("http://0.0.0.0/request/123/123", url)
      assert.equal("mockbin.com", host)
    end)
  end)

end)
