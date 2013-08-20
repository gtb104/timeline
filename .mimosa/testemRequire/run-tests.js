var assert = chai.assert;
var expect = chai.expect;
var should = chai.should();
chai.Assertion.includeStack = true;
mocha.setup(window.MIMOSA_TEST_MOCHA_SETUP);

require.config(window.MIMOSA_TEST_REQUIRE_CONFIG);
require(['../testem'], function(){
  require(window.MIMOSA_TEST_SPECS, function(module){
    mocha.run();
  });
});
