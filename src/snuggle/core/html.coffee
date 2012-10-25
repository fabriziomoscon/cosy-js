'use strict'

# cosy.js
#
# @copyright BraveNewTalent Ltd 2012
# @see http://github.com/BraveNewTalent/cosy-js
# @see http://opensource.org/licenses/mit-license.php MIT License


html = (tag, attrs, content) ->
  element = $("<#{tag} />")
  element.attr attrs
  element.html content
  element

tags = [
  "a"
  "abbr"
  "acronym"
  "address"
  "applet"
  "area"
  "b"
  "base"
  "basefont"
  "bdo"
  "big"
  "blockquote"
  "body"
  "br"
  "button"
  "caption"
  "center"
  "cite"
  "code"
  "col"
  "colgroup"
  "dd"
  "del"
  "dfn"
  "dir"
  "div"
  "dl"
  "dt"
  "em"
  "fieldset"
  "font"
  "form"
  "frame"
  "frameset"
  "h1"
  "h2"
  "h3"
  "h4"
  "h5"
  "h6"
  "head"
  "hr"
  "html"
  "i"
  "iframe"
  "img"
  "input"
  "ins"
  "isindex"
  "kbd"
  "label"
  "legend"
  "li"
  "link"
  "map"
  "menu"
  "meta"
  "noframes"
  "noscript"
  "object"
  "ol"
  "optgroup"
  "option"
  "p"
  "param"
  "pre"
  "q"
  "s"
  "samp"
  "script"
  "select"
  "small"
  "span"
  "strike"
  "strong"
  "style"
  "sub"
  "sup"
  "table"
  "tbody"
  "td"
  "textarea"
  "tfoot"
  "th"
  "thead"
  "title"
  "tr"
  "tt"
  "u"
  "ul"
  "var"
]

for tag in tags
  do (tag) ->
    exports[tag] = (attrs, content) ->
      html tag, attrs, content

