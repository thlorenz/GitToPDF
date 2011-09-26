htmlTemplate =
"""
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>SyntaxHighlighter Autoloader Demo</title>
    <script type="text/javascript" src="{ROOT}/scripts/XRegExp.js"></script> <!-- XRegExp is bundled with the final shCore.js during build -->
    <script type="text/javascript" src="{ROOT}/scripts/shCore.js"></script>
    <script type="text/javascript" src="{ROOT}/scripts/shAutoloader.js"></script>
    <link type="text/css" rel="stylesheet" href="{ROOT}/styles/shCore.css"/>
    <link type="text/css" rel="Stylesheet" href="{ROOT}/styles/shThemeDefault.css" />
  </head>

  <body>

    {CONTENT}

    <script type="text/javascript">
      SyntaxHighlighter.autoloader(
        'applescript			{ROOT}/scripts/shBrushAppleScript.js',
        'actionscript3 as3		{ROOT}/scripts/shBrushAS3.js',
        'bash shell sh				{ROOT}/scripts/shBrushBash.js',
        'coldfusion cf			{ROOT}/scripts/shBrushColdFusion.js',
        'cpp c					{ROOT}/scripts/shBrushCpp.js',
        'c# c-sharp csharp cs		{ROOT}/scripts/shBrushCSharp.js',
        'css					{ROOT}/scripts/shBrushCss.js',
        'delphi pascal			{ROOT}/scripts/shBrushDelphi.js',
        'diff patch pas			{ROOT}/scripts/shBrushDiff.js',
        'erl erlang				{ROOT}/scripts/shBrushErlang.js',
        'groovy					{ROOT}/scripts/shBrushGroovy.js',
        'java	jar				{ROOT}/scripts/shBrushJava.js',
        'jfx javafx				{ROOT}/scripts/shBrushJavaFX.js',
        'js json jscript javascript	{ROOT}/scripts/shBrushJScript.js',
        'perl pl				{ROOT}/scripts/shBrushPerl.js',
        'php					{ROOT}/scripts/shBrushPhp.js',
        'text plain txt				{ROOT}/scripts/shBrushPlain.js',
        'py python				{ROOT}/scripts/shBrushPython.js',
        'ruby rails ror rb		{ROOT}/scripts/shBrushRuby.js',
        'scala					{ROOT}/scripts/shBrushScala.js',
        'sql					{ROOT}/scripts/shBrushSql.js',
        'vb vbnet				{ROOT}/scripts/shBrushVb.js',
        'xml xhtml xslt html	{ROOT}/scripts/shBrushXml.js'
      );

      SyntaxHighlighter.all();
    </script>

  </body>
"""

codeTemplate=
  """
    <pre class="brush: {BRUSH};">
    {CODE}
    </pre>
  """

codeToHtml = (brush, code) ->
  codeTemplate
    .replace(///{BRUSH}///, brush)
    .replace(///{CODE}///, code)

highlightHtml = (root, codeHtml) ->
  htmlTemplate
    .replace(///{ROOT}///g, root)
    .replace(///{CONTENT}///, codeHtml)

module.exports = { codeToHtml, highlightHtml }

return

# Testing Area

root = "syntaxhighlighter"
code =
  """
    function helloSyntaxHighlighter()
    {
      return "hi!";
    }
  """
extension = "js"


codeHtml = codeToHtml extension, code
html = highlightHtml root, codeHtml

console.log html

