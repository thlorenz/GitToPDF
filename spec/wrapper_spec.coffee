sut = require '../lib/wrapper.coffee'

wrap = (line, columns) -> sut.wrapLine line, columns
wi = sut.wrapInsert

describe 'given 123 56 89', ->
  line = '123 56 89'
  it "wrapped to 9 returns 123 56 89", ->
    expect(wrap line, 9).line.toEqual(line)

  it "wrapped to 9 returns unchanged", ->
    expect(wrap line, 9).changed.toBeFalse()

  it "wrapped to 8 returns 123 56#{wi}89", ->
    expect(wrap line, 8).line.toEqual("123 56#{wi}89")

  it "wrapped to 5 returns 123#{wi}56 89", ->
    expect(wrap line, 5).line.toEqual("123#{wi}56 89")

  it "wrapped to 4 returns 123#{wi}56#{wi}89", ->
    expect(wrap line, 4).line.toEqual("123#{wi}56#{wi}89")

  it "wrapped to 3 returns 123#{wi}56#{wi}89", ->
    expect(wrap line, 3).line.toEqual("123#{wi}56#{wi}89")
