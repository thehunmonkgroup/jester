require "jester.support.file"
local core = require("jester.core")
describe("core", function()
  setup(function()
    core.bootstrap_test()
  end)
  describe("logger", function()
    it("outputs correct level", function()
      local level, output = core.log.info("test")
      assert.is.equal(level, "info")
    end)
    it("outputs default prefix", function()
      local level, output = core.log.info("test")
      assert.is.equal(output, "[JESTER] test")
    end)
    it("doesn't log on debug with info level", function()
      local level, output = core.log.debug("test")
      assert.is_nil(output)
    end)
    it("uses custom level when passed", function()
      core.log.level = "err"
      local level, output = core.log.warning("test")
      assert.is_nil(output)
      local level, output = core.log.err("test")
      assert.is.equal(level, "err")
      finally(function() core.log.level = "info" end)
    end)
    it("uses custom prefix when passed", function()
      core.log.prefix = "test"
      local level, output = core.log.info("test")
      assert.is.equal(output, "[TEST] test")
      finally(function() core.log.prefix = "jester" end)
    end)
    it("correctly handles string tokens", function()
      local level, output = core.log.info("test %d %s", 1, "test")
      assert.is.equal(output, "[JESTER] test 1 test")
    end)
    it("correctly handles formatter function", function()
      local level, output = core.log.info(function(t) return t end, "test")
      assert.is.equal(output, "[JESTER] test")
    end)
    it("throws on missing level", function()
      core.log.level = "test"
      assert.has_error(function() core.log.info("test") end, "ERROR: missing log level 'test'")
      finally(function() core.log.level = "info" end)
    end)
    describe("custom", function()
      it("correctly loads with default level", function()
        local logger = core.logger()
        local level, output = logger.info("test")
        assert.is.equal(level, "info")
      end)
      it("correctly handles custom modes", function()
        local modes = {
          { name = "test", color = "\27[36m", },
        }
        local logger = core.logger({level = "test", modes = modes})
        local level, output = logger.test("test")
        assert.is.equal(level, "test")
      end)
      it("correctly logs to file", function()
        local filepath = "/tmp/core_logger_test"
        os.remove(filepath)
        local logger = core.logger({outfile = filepath})
        local level, output = logger.info("test")
        assert.is_true(file_exists(filepath))
        finally(function() os.remove(filepath) end)
      end)
    end)
  end)
end)
