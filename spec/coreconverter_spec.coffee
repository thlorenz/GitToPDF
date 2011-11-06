sut = require '../lib/coreconverter.coffee'

describe 'create html content', ->
  doc0 = { fullname: "socketio/lib/file", html: "<span>doc0</span>" }
  doc1 = { fullname: "socketio/lib/lib1/file", html: "<span>doc1</span>" }
  doc2 = { fullname: "socketio/lib/lib2/file1", html: "<span>doc2</span>" }
  doc3 = { fullname: "socketio/lib/lib2/file2", html: "<span>doc3</span>" }


  doc4 = { fullname: "socketio/test/file", html: "<span>doc4</span>" }
  doc5 = { fullname: "socketio/test/lib1/file1", html: "<span>doc5</span>" }
  doc6 = { fullname: "socketio/test/lib1/file2", html: "<span>doc6</span>" }
  doc7 = { fullname: "socketio/test/lib2/file", html: "<span>doc7</span>" }

  docs = [ doc6, doc2, doc7, doc1, doc4, doc3, doc0, doc5 ]

  expectedHtml = '<span>doc0</span><br/><span>doc1</span><br/><span>doc2</span><br/><span>doc3</span><br/><span>doc4</span><br/><span>doc5</span><br/><span>doc6</span><br/><span>doc7</span>'

  html = sut.createHtmlContent docs

  it "orders paths and adds html to the html content in that order", ->
    expect(html).toEqual expectedHtml

describe 'when subfolders have no files and i create html content', ->
  html = sut.createHtmlContent [
    fullname: 'socket_io/package.json'
    folderfullname: 'socket_io'
    depth: '1'
    html: "doc0"
  ,
    fullname: 'socket_io/support/examples/unix.js'
    folderfullname: 'socket_io/support/examples'
    depth: '3'
    html: "doc1"
  ]

  expectedHeader = '<span>(socket_io/support)</span><br/>'
  it "adds headers for folders without files", ->
    expect(html).toContain expectedHeader

