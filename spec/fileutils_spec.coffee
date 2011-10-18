sut = require '../lib/fileutils.coffee'


describe 'comparePaths', ->

  check = (a, b, r) ->
    it "returns #{1} when comparing #{a} and #{b}", ->
      expect(sut.comparePaths(a, b)).toEqual r

  check "a", "z", -1
  check "z", "a",  1
  check "a/a", "a/b", -1
  check "a/b", "a/a",  1
  check "a/a/a", "a/a", -1
  check "a/a", "a/a/a",  1
