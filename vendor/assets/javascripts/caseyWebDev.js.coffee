###!
caseyWebDev (requires jQuery)
Casey Foster
caseyWebDev
caseywebdev.com
###
if not caseyWebDev? and jQuery?
  $ = jQuery
  window.caseyWebDev = class
    @init: ->
      for k, v of @
        v?.init?()
      $ => @load()
    @load: ->
      for k, v of @
        v?.load?()
      @dom()
      $("body").on "DOMSubtreeModified", => @dom() if not @domLocked
    @dom: ->
      @domLocked = true
      for k, v of @
        v?.dom?()
      @domLocked = false
    @domLocked = false
    @abortXhr: ->
      for k, v of @
        v?.abortXhr?()
    @Util: class
      @init: ->
        #extend jQuery with some handy functions
        $.prettyUrl = (s, delimiter = "-") ->
          $.trim(s.toLowerCase().replace(/[\W_]/g, " ").replace(/\s+/g, " ")).replace /\s+/g, delimiter
        $.escapeHtml = (s, quotes, query) ->
          s = $("<div/>").text(s).html()
          s = s.replace(/"/g, "&quot;").replace /'/g, "&#039;" if quotes
          s = s.replace " ", "+" if query
          s
        $.unescapeHtml = (s) ->
          $("<div/>").html(s).text()
        $.sortByKey = (o) ->
          if typeof o isnt "object"
            return o
          copy = []
          for k, v of o
            copy.push k: k, v: v
          o = {}
          copy.sort (a, b) -> if a.k < b.k then -1 else 1
          for v in copy
            o[v.k] = v.v
          o
        $.sortWithKey = (o, fn) ->
          if typeof o isnt "object"
            return o
          copy = []
          for k, v of o
            copy.push k: k, v: v
          o = {}
          copy.sort fn
          for v in copy
            o[v.k] = v.v
          o
        $.scrollTo = $.fn.scrollTo = (tar = 0, duration, callback) ->
          if tar instanceof jQuery
            val = tar.offset().top
          else if not isNaN parseInt tar
            val = tar
          else
            val = $(tar).offset().top
          $(if @ instanceof jQuery then @ else if $.browser.webkit then document.body else document.documentElement).animate scrollTop: val, duration, callback
    @Placeholder: class
      @locked: false
      @load: ->
        #hijack jQuery's .val() to it will return an empty string if Placeholder says it should
        $.fn._val = $.fn.val
        $.fn.val = (str) ->
          unless str?
            if $(@).data "empty" then "" else $(@)._val()
          else
            $(@).each -> $(@)._val str
      @dom: ->
        if not @locked
          @locked = true
          $("input[data-placeholder], textarea[data-placeholder]").each ->
            $t = $ @
            password = $t.data("password")?
            placeholder = $t.data "placeholder"
            if placeholder and not $t.data("empty")?
              $t[0].type = "password" if password
              unless password and $.browser.msie and $.browser.version.split(".")[0] < 9
                if not $t.val() or $t.val() is placeholder
                  $t.data "empty", true
                  $t.val placeholder
                  $t[0].type = "" if password
                else
                  $t.data "empty", false
                $t.attr placeholder: placeholder, title: placeholder
                $t.focus(->
                  $t.val "" if $t.data "empty"
                  if password
                    $t[0].type = "password"
                    $t.attr "placeholder", placeholder
                  $t.data "empty", false
                ).blur ->
                  if $t.val()
                    $t.data "empty", false
                  else
                    $t.val placeholder
                    $t.data "empty", true
                    $t[0].type = "" if password
          @locked = false
    @PopUp: class
      @load: ->
        unless $("#caseyWebDevPopUp").length
          @$table = $("""<table id="caseyWebDevPopUp"><tbody><tr><td><div/></td></tr></tbody></table>""").css "opacity", 0
          @hide()
          $("body").append @$table
          @$td = @$table.find "td"          
          @$div = @$td.find "div"
          $(window).on "scroll resize orientationchange", => @correctUi()
          @$td.on "click", =>
            @$div.find(".click").click()
          @$div.on "click", false
          @$div.on "click", ".hide-on-click", => @hide()
          $(document).keydown (e) =>
            if @$table.css("display") is "block" and not $("body :focus").length
              if e.keyCode is 13 and @$div.find(".enter").length
                @$div.find(".enter").click()
              else if e.keyCode is 27 and @$div.find(".esc").length
                @$div.find(".esc").click()
              else
                return true
              false
          @correctUi()
      @correctUi: ->
        @$td.width($(window).width()).height $(window).height()
      @hide: ->
        @$table.stop().animate opacity: 0, 250, => @$table.css "display", "none"
      @show: (html, duration, callback) ->
        $("body :focus").blur()
        @$div.html html
        @$table.stop().css("display", "block").animate opacity: 1, 250
        clearTimeout @timer if @timer?
        @timer = setTimeout =>
          @hide()
          callback?()
        , duration if duration
    @LiveSearch: class
      @load: ->
        $("input, textarea").attr autocomplete: "off"
      @trim: (s) ->
        $.trim s.replace /\s+/g, " "
      @dom: ->
        $("*[data-live-search-callback]").each (i, e) =>
          $wrap = $ e
          unless $wrap.data("liveSearchCache")?
            $wrap.data
              liveSearchCache: []
              liveSearchId: 0
              liveSearchAjax: {}
              liveSearchLastQ: null
              liveSearchPage: 0
              liveSearchHoldHover: false
            $q = $wrap.find ".q"
            $results = $wrap.find ".results"
            @query $wrap if $q.is ":focus"
            $wrap.hover(->
              $wrap.data hover: true
            , ->
              $wrap.data hover: false
              $results.css display: "none" unless $q.is(":focus") or $wrap.data "liveSearchHoldHover"
            ).mouseover ->
              $wrap.data liveSearchHoldHover: false
            $q.blur(->
              setTimeout ->
                $results.css display: "none" unless $wrap.data "hover"
              , 0
            ).focus(->
              $wrap.data liveSearchHoldHover: false
            ).keydown((e) =>
              switch e.keyCode
                when 13 then $wrap.find(".selected").click()
                when 38 then @select $wrap, "prev"
                when 40 then @select $wrap, "next"
                when 27
                  setTimeout ->
                    $results.css display: "none"
                  , 0
                  $q.blur()
                else
                  setTimeout =>
                    @query($wrap) if $q.is ":focus"
                  , 0
                  return true
              false
            ).on "focus keyup change", =>
              @query $wrap
            $results.on("mouseenter", ".result", ->
              $results.find(".result.selected").removeClass "selected"
              $(@).addClass "selected"
            ).on "click", ".result", (e) =>
              $t = $ e.currentTarget
              $results.find(".result.selected").removeClass "selected"
              $t.addClass "selected"
              if $t.hasClass "prev"
                @page $wrap, $wrap.data("liveSearchPage")-1, true
                $wrap.data "liveSearchHoldHover", true
              else if  $t.hasClass "next"
                @page $wrap, $wrap.data("liveSearchPage")+1
                $wrap.data "liveSearchHoldHover", true
              else if $t.hasClass "submit"
                $t.parents("form").submit()
              if $t.hasClass "hide"
                $("#search .q").blur()
                $("#search .results").css "display", "none"
      @page: ($wraps, n, prev) ->
        $wraps.each ->
          $wrap = $ @
          $results = $wrap.find ".results"
          n = Math.min $results.find(".page").length-1, Math.max n, 0
          $results.find(".result.selected").removeClass "selected"
          $results.find(".page").css("display", "none").eq(n).removeAttr("style").find(".result:not(.prev):not(.next)")[if prev then "last" else "first"]().addClass "selected"
          $wrap.data "liveSearchPage", n
      @query: ($wraps, urlN = 1) ->
        $wraps.each (i, e) =>
          $wrap = $ e
          $results = $wrap.find ".results"
          callback = eval $wrap.data("liveSearchCallback")
          q = @trim $wrap.find(".q").val()
          t = new Date().getTime()
          $results.css "display", "block"
          empty = "liveSearchEmpty" of $wrap.data()
          unless q or empty
            $results.css("display", "none").html ""
            $wrap.removeClass "loading"
          else if q isnt $wrap.data("liveSearchLastQ") or urlN > 1
            callback $wrap
            clearTimeout $wrap.data("liveSearchTimeout")
            $wrap.data("liveSearchAjax").abort?()
            if $wrap.data("liveSearchCache")["liveSearchCache_#{urlN}_"+q]?
              callback $wrap, $wrap.data("liveSearchCache")["liveSearchCache_#{urlN}_"+q], urlN
              $wrap.removeClass "loading"
              @query $wrap, urlN+1 if $wrap.data("liveSearchUrl#{urlN+1}")?
            else
              $wrap.addClass("loading").data "liveSearchTimeout",
                setTimeout =>
                  check = $wrap.data("liveSearchId", $wrap.data("liveSearchId")+1).data "liveSearchId"
                  handleData = (data) =>
                    $wrap.data("liveSearchCache")["liveSearchCache_#{urlN}_"+q] = data
                    if check is $wrap.data("liveSearchId") and (@trim($wrap.find(".q").val()) or empty)
                      $wrap.removeClass "loading"
                      callback $wrap, data, urlN
                    @query $wrap, urlN+1 if $wrap.data "liveSearchUrl"+(urlN+1)
                  if $wrap.data("liveSearchJs")?
                    handleData eval($wrap.data "liveSearchJs")(q)
                  else if $wrap.data("liveSearchUrl")?
                    $wrap.data liveSearchAjax: $.getJSON($wrap.data("liveSearchUrl#{if urlN is 1 then "" else urlN}"), q: q, handleData)
                , $wrap.data("liveSearchDelay") ? 0
          $wrap.data "liveSearchLastQ", q
      @select: ($wraps, dir) ->
        $wraps.each (i, e) =>
          $wrap = $ e
          $page = $wrap.find(".page").eq $wrap.data "liveSearchPage"
          $page.find(".result")[if dir is "prev" then "first" else "last"]().addClass "selected" unless $page.find(".result.selected").removeClass("selected")[dir]().addClass("selected").length
          if $page.find(".result.selected").hasClass "prev"
            @page $wrap, $wrap.data("liveSearchPage")-1, true
          else if $page.find(".result.selected").hasClass "next"
            @page $wrap, $wrap.data("liveSearchPage")+1
    @Tooltip: class
      @load: ->
        $("body").on "mouseenter focus", "*[data-tooltip-text]", (e) ->
          $t = $ @
          unless $t.data "hover" or $t.data "focus"
            unless $t.data("tooltipDiv")?
              $t.data "tooltipDiv", $ """<div class="caseyWebDevTooltip"/>"""
              $t.parent().append $t.data "tooltipDiv"
            pos = $t.data("tooltipPosition") ? "top"
            $t.data("tooltipDiv").html """#{$t.data "tooltipText"}<div class="caseyWebDevTooltipArrow #{pos}"></div>"""
            tL = $t.position().left+parseInt $t.css "marginLeft"
            tT = $t.position().top+parseInt $t.css "marginTop"
            hW = ($t.outerWidth()-$t.data("tooltipDiv").outerWidth())/2
            hH = ($t.outerHeight()-$t.data("tooltipDiv").outerHeight())/2
            dir =
              top:
                left: hW
                top: -$t.data("tooltipDiv").outerHeight()-15
                dLeft: 0
                dTop: 10
              right:
                left: $t.outerWidth()+15
                top: hH
                dLeft: -10
                dTop: 0
              bottom:
                left: hW
                top: $t.outerHeight()+15
                dLeft: 0
                dTop: -10
              left:
                left: -$t.data("tooltipDiv").outerWidth()-15
                top: hH
                dLeft: 10
                dTop: 0
            $t.data("tooltipDiv").css(
              left: tL+dir[pos].left
              top: tT+dir[pos].top
              opacity: 0
              display: "block"
            ).stop().animate
              left: "+="+dir[pos].dLeft
              top: "+="+dir[pos].dTop
              opacity: 1
            , $t.data("tooltipSpeed") ? 200
            $t.on "mouseleave blur", (e) ->
              $t.data (if e.type is "mouseleave" then "hover" else "focus"), false
              unless $t.data "hover" or $t.data "focus"
                $t.data("tooltipDiv").stop().animate(
                  left: "+=#{-dir[pos].dLeft}"
                  top: "+=#{-dir[pos].dTop}"
                  opacity: 0
                , $t.data("tooltipSpeed") ? 200
                , -> $(@).css "display", "none").off e
          $t.data (if e.type is "mouseenter" then "hover" else "focus"), true
    @State: class
      @xhr: {}
      @cache: {}
      @refresh: false
      @query: "pushState"
      @prefix: "<!--pushState-->\n"
      @init: ->
        if history.state?
          history.replaceState true, null
        $(window).on("popstate", (e) =>
          if e.originalEvent.state?
            @push location.href
          else
            history.replaceState true, null
        ).on "click", "*[data-push-state]", (e) =>
          $t = $ e.currentTarget
          @push if $t.data "pushState" then $t.data "pushState" else $t.attr "href"
          false
      @updateCache: (url, o) ->
        if @cache[url]?
          $.extend @cache[url], o
        else
          @cache[url] = o
      @fullUrl: (url) ->
        if url.match /^\w+:/ then url else location.protocol+"//"+location.host+url
      @push: (url) ->
        url = @fullUrl url
        if location.protocol is url.match(/^\w+:/)[0] and history.pushState? and not @refresh
          @xhr.abort?()
          @clear url
          if @cache[url]? and @cache[url].cache isnt false
            @change url
          else
            @before url
            @xhr = $.get("#{url}#{if "?" in url then "&" else "?"}#{@query}", null, (data) =>
              if data[0...@prefix.length] is @prefix
                @updateCache url,
                  title: /^[^\n]*\n([^\n]*)\n/.exec(data)[1]
                  #[\s\S] is synonymous with . except that the JS . doesn't match \n like [\s\S] does
                  html: /^(?:[^\n]*\n){2}([\s\S]*)$/.exec(data)[1]
                @after url
                @change url
              else
                location.assign url
            ).error -> location.assign url
        else
          location.assign url
      @change: (url) ->
        history.pushState true, null, url if location.href isnt url
        @parse url
      @clear: (url) ->
      @before: (url) ->
      @after: (url) ->
      @parse: (url) ->
    @LazyLoad: class
      @tolerance: 100
      @load: ->
        @update()
        $(window).on "scroll resize", => @update()
      @update: ->
        $("img[data-lazy]").each (i, e) =>
          $t = $ e
          if $t.css("display") isnt "none" && $(window).scrollTop()+$(window).outerHeight() >= $t.offset().top-@tolerance
            url = $t.data "lazy"
            $t.removeAttr("data-lazy").attr "src", url
    @Konami: (callback, onlyOnce = false, code = "38,38,40,40,37,39,37,39,66,65,13", swipeCode = "up,up,down,down,left,right,left,right,tap,tap,tap") ->
      keysPressed = []
      touchEvents = []
      tap = false
      startX = startY = dX = dY = 0
      keyDownEvent = (e) ->
        keysPressed.push e.keyCode
        if keysPressed.toString()[-code.length..-1] is code
          $(document).off "keydown", keyDownEvent if onlyOnce
          keysPressed = []
          e.preventDefault()
          callback()
      touchStartEvent = (e) ->
        e = e.originalEvent
        if e.touches.length is 1
          touch = e.touches[0]
          {screenX: startX, screenY: startY} = touch
          tap = tracking = true
      touchMoveEvent = (e) ->
        e = e.originalEvent
        if e.touches.length is 1 and tap
          touch = e.touches[0]
          dX = touch.screenX-startX
          dY = touch.screenY-startY
          rightLeft = if dX > 0 then "right" else "left"
          downUp = if dY > 0 then "down" else "up"
          val = if Math.abs(dX) > Math.abs dY then rightLeft else downUp
          touchEvents.push val
          tap = false
          checkEvents e
      touchEndEvent = (e) ->
        e = e.originalEvent
        if e.touches.length is 0 and tap
          touchEvents.push "tap"
          checkEvents e
      checkEvents = (e) ->
        if touchEvents.toString()[-swipeCode.length..-1] is swipeCode
          if onlyOnce
            $(document).off "touchmove", touchMoveEvent
            $(document).off "touchend", touchEndEvent
          touchEvents = []
          e.preventDefault()
          callback()
      $(document).on "keydown", keyDownEvent
      $(document).on "touchstart", touchStartEvent
      $(document).on "touchmove", touchMoveEvent
      $(document).on "touchend", touchEndEvent
    @Cookie: (name, value, options = {}) =>
      if typeof name is "object"
        @Cookie n, v, value for n, v of name
      else if typeof name is "string" and value isnt undefined
        options.expires = -1 if value is null
        value ||= ""
        params = []
        params.push "; Expires=#{if options.expires.toGMTString? then options.expires.toGMTString() else new Date(new Date().getTime()+options.expires*1000*60*60*24).toGMTString()}" if options.expires
        params.push "; Path=#{options.path}" if options.path
        params.push "; Domain=#{options.domain}" if options.domain
        params.push "; HttpOnly" if options.httpOnly
        params.push "; Secure" if options.secure
        document.cookie = "#{encodeURIComponent name}=#{encodeURIComponent value}#{params.join ""}"
      else
        cookies = {}
        for cookie in decodeURIComponent(document.cookie).split /\s*;\s*/
          {1: n, 2: v} = /^([^=]*)\s*=\s*(.*)$/.exec cookie
          if typeof name is "string" and name is n
            return v
          else if not name?
            cookies[n] = v
        if not name then cookies else null
