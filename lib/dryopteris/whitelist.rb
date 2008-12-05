#
#  HTML whitelist lifted from HTML5 sanitizer code
#    http://code.google.com/p/html5lib/
#

module Dryopteris
  module WhiteList
    # <html5_license>
    #
    #   Copyright (c) 2006-2008 The Authors
    #
    #   Contributors:
    #   James Graham - jg307@cam.ac.uk
    #   Anne van Kesteren - annevankesteren@gmail.com
    #   Lachlan Hunt - lachlan.hunt@lachy.id.au
    #   Matt McDonald - kanashii@kanashii.ca
    #   Sam Ruby - rubys@intertwingly.net
    #   Ian Hickson (Google) - ian@hixie.ch
    #   Thomas Broyer - t.broyer@ltgt.net
    #   Jacques Distler - distler@golem.ph.utexas.edu
    #   Henri Sivonen - hsivonen@iki.fi
    #   The Mozilla Foundation (contributions from Henri Sivonen since 2008)
    #
    #   Permission is hereby granted, free of charge, to any person
    #   obtaining a copy of this software and associated documentation
    #   files (the "Software"), to deal in the Software without
    #   restriction, including without limitation the rights to use, copy,
    #   modify, merge, publish, distribute, sublicense, and/or sell copies
    #   of the Software, and to permit persons to whom the Software is
    #   furnished to do so, subject to the following conditions:
    #
    #   The above copyright notice and this permission notice shall be
    #   included in all copies or substantial portions of the Software.
    #
    #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    #   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    #   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    #   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    #   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    #   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    #   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    #   DEALINGS IN THE SOFTWARE.
    #
    # </html5_license>

    ACCEPTABLE_ELEMENTS = %w[a abbr acronym address area b big blockquote br
      button caption center cite code col colgroup dd del dfn dir div dl dt
      em fieldset font form h1 h2 h3 h4 h5 h6 hr i img input ins kbd label
      legend li map menu ol optgroup option p pre q s samp select small span
      strike strong sub sup table tbody td textarea tfoot th thead tr tt u
      ul var]

    MATHML_ELEMENTS = %w[maction math merror mfrac mi mmultiscripts mn mo
      mover mpadded mphantom mprescripts mroot mrow mspace msqrt mstyle msub
      msubsup msup mtable mtd mtext mtr munder munderover none]

    SVG_ELEMENTS = %w[a animate animateColor animateMotion animateTransform
      circle defs desc ellipse font-face font-face-name font-face-src g
      glyph hkern image linearGradient line marker metadata missing-glyph
      mpath path polygon polyline radialGradient rect set stop svg switch
      text title tspan use]

    ACCEPTABLE_ATTRIBUTES = %w[abbr accept accept-charset accesskey action
      align alt axis border cellpadding cellspacing char charoff charset
      checked cite class clear cols colspan color compact coords datetime
      dir disabled enctype for frame headers height href hreflang hspace id
      ismap label lang longdesc maxlength media method multiple name nohref
      noshade nowrap prompt readonly rel rev rows rowspan rules scope
      selected shape size span src start style summary tabindex target title
      type usemap valign value vspace width xml:lang]

    MATHML_ATTRIBUTES = %w[actiontype align columnalign columnalign
      columnalign columnlines columnspacing columnspan depth display
      displaystyle equalcolumns equalrows fence fontstyle fontweight frame
      height linethickness lspace mathbackground mathcolor mathvariant
      mathvariant maxsize minsize other rowalign rowalign rowalign rowlines
      rowspacing rowspan rspace scriptlevel selection separator stretchy
      width width xlink:href xlink:show xlink:type xmlns xmlns:xlink]

    SVG_ATTRIBUTES = %w[accent-height accumulate additive alphabetic
       arabic-form ascent attributeName attributeType baseProfile bbox begin
       by calcMode cap-height class color color-rendering content cx cy d dx
       dy descent display dur end fill fill-rule font-family font-size
       font-stretch font-style font-variant font-weight from fx fy g1 g2
       glyph-name gradientUnits hanging height horiz-adv-x horiz-origin-x id
       ideographic k keyPoints keySplines keyTimes lang marker-end
       marker-mid marker-start markerHeight markerUnits markerWidth
       mathematical max min name offset opacity orient origin
       overline-position overline-thickness panose-1 path pathLength points
       preserveAspectRatio r refX refY repeatCount repeatDur
       requiredExtensions requiredFeatures restart rotate rx ry slope stemh
       stemv stop-color stop-opacity strikethrough-position
       strikethrough-thickness stroke stroke-dasharray stroke-dashoffset
       stroke-linecap stroke-linejoin stroke-miterlimit stroke-opacity
       stroke-width systemLanguage target text-anchor to transform type u1
       u2 underline-position underline-thickness unicode unicode-range
       units-per-em values version viewBox visibility width widths x
       x-height x1 x2 xlink:actuate xlink:arcrole xlink:href xlink:role
       xlink:show xlink:title xlink:type xml:base xml:lang xml:space xmlns
       xmlns:xlink y y1 y2 zoomAndPan]

    ATTR_VAL_IS_URI = %w[href src cite action longdesc xlink:href xml:base]

    ACCEPTABLE_CSS_PROPERTIES = %w[azimuth background-color
      border-bottom-color border-collapse border-color border-left-color
      border-right-color border-top-color clear color cursor direction
      display elevation float font font-family font-size font-style
      font-variant font-weight height letter-spacing line-height overflow
      pause pause-after pause-before pitch pitch-range richness speak
      speak-header speak-numeral speak-punctuation speech-rate stress
      text-align text-decoration text-indent unicode-bidi vertical-align
      voice-family volume white-space width]

    ACCEPTABLE_CSS_KEYWORDS = %w[auto aqua black block blue bold both bottom
      brown center collapse dashed dotted fuchsia gray green !important
      italic left lime maroon medium none navy normal nowrap olive pointer
      purple red right solid silver teal top transparent underline white
      yellow]

    ACCEPTABLE_SVG_PROPERTIES = %w[fill fill-opacity fill-rule stroke
      stroke-width stroke-linecap stroke-linejoin stroke-opacity]

    ACCEPTABLE_PROTOCOLS = %w[ed2k ftp http https irc mailto news gopher nntp
      telnet webcal xmpp callto feed urn aim rsync tag ssh sftp rtsp afs]

    # subclasses may define their own versions of these constants
    ALLOWED_ELEMENTS = ACCEPTABLE_ELEMENTS + MATHML_ELEMENTS + SVG_ELEMENTS
    ALLOWED_ATTRIBUTES = ACCEPTABLE_ATTRIBUTES + MATHML_ATTRIBUTES + SVG_ATTRIBUTES
    ALLOWED_CSS_PROPERTIES = ACCEPTABLE_CSS_PROPERTIES
    ALLOWED_CSS_KEYWORDS = ACCEPTABLE_CSS_KEYWORDS
    ALLOWED_SVG_PROPERTIES = ACCEPTABLE_SVG_PROPERTIES
    ALLOWED_PROTOCOLS = ACCEPTABLE_PROTOCOLS

    VOID_ELEMENTS = %w[
      base
      link
      meta
      hr
      br
      img
      embed
      param
      area
      col
      input
    ]
  end
end
