###! Extrascore (requires jQuery, Underscore and Underscore.string) by Casey Foster (caseywebdev.com) ###

# Check dependencies
if not Extrascore? and jQuery? and _? and _.str?
  
  # Use the jQuery shortcut
  $ = jQuery
  
  # Mixin Underscore.string
  _.mixin _.str.exports()
  
  # Define the Extrascore object
  window.Extrascore =
    
    # Mixins for Underscore
    Mixins:
    
      # Mass method call for every child of obj
      mass: (obj, str, args...) ->
        _.each obj, (val) -> val?[str]?(args...)
          
      # Initialize an object by calling init on children and then assigning the load method to jQuery's DOM ready call
      # This is a special _.mass() function
      init: (obj) ->
        
        # Call on jQuery's DOM ready call
        load = (obj) ->
          _.mass obj, 'load'
          dom obj
          $('body').on 'DOMSubtreeModified', (e) -> dom obj, e unless obj._extrascoreDomLocked
          
        # Call on every DOMSubtreeModified event (use carefully, doesn't work in Opera *shocking*)
        dom = (obj, e) ->
          obj._extrascoreDomLocked = true
          _.mass obj, 'dom', e
          obj._extrascoreDomLocked = false
        
        # Call 'init()' on all children of obj if the method exists
        _.mass obj, 'init'
        
        $ -> load obj
      
      # Clean a string for use in a URL or query
      clean: (str, opt={}) ->
        opt = _.extend
          delimiter: ' '
          alphanumeric: false
          downcase: false
        , opt
        str = str+''
        str = str.toLowerCase() if opt.downcase
        str = str.replace(/'/g, '').replace(/[^\w\s]|_/g, ' ') if opt.alphanumeric
        _.strip(str.replace /\s+/, ' ').replace /\ /g, opt.delimiter
      
      # Sort an object by key for iteration
      sortByKey: (obj) ->
        newObj = {}
        _.chain(obj)
          .map (val, key) -> [key, val]
          .sortBy (val) -> val[0]
          .each (val) -> newObj[val[0]] = val[1]
        newObj
      
      # A quick zip to the top of the page, or optionally to an integer or jQuery object specified by `val`
      scrollTo: (val = 0, duration, callback) ->
        if val instanceof $
          val = val.offset().top
        $(if $.browser.webkit then document.body else document.documentElement).animate scrollTop: val, duration, callback
      
      # Get a full URL from a relative url
      url: (path = '') ->
          
          # See if it's already a URL
          if path.match /^\w+:/
            path
          
          # See if it's a URL looking for a protocol
          else if _.startsWith path, '//'
            location.protocol+path
          
          # See if it's relative to the domain root
          else if _.startsWith path, '/'
            location.protocol+'//'+location.host+path
            
          # Otherwise it must be relative to the current location
          else
            location.href+path
    
    # Extensions for Underscore (more of individual classes using Underscore for the namespace then actual extentions)
    Extensions:
      
      # Placeholder for lame browsers
      Placeholder:
        
        # After the DOM is loaded
        load: ->
          
          # Hijack jQuery's .val() so it will return an empty string if Placeholder says it should
          $.fn._val = $.fn.val
          $.fn.val = (str) ->
            if str?
              $(@).each -> $(@)._val str
            else
              if $(@).data 'empty' then '' else $(@)._val()
                  
        # Check for new inputs or textareas than need to be initialized with Placeholder
        dom: ->
          $('input[data-placeholder], textarea[data-placeholder]').each ->
            $t = $ @
            if $t.data('placeholder')? and not $t.data('empty')?
              password = $t.data('password')?
              placeholder = $t.data 'placeholder'
              $t[0].type = 'password' if password
              unless password and $.browser.msie and $.browser.version.split('.') < 9
                if not $t.val() or $t.val() is placeholder
                  $t.data 'empty', true
                  $t.val placeholder
                  $t[0].type = "" if password
                else
                  $t.data 'empty', false
                $t.attr placeholder: placeholder, title: placeholder
                $t.focus(->
                  $t.val '' if $t.data 'empty'
                  if password
                    $t[0].type = 'password'
                    $t.attr 'placeholder', placeholder
                  $t.data 'empty', false
                ).blur ->
                  if $t.val()
                    $t.data 'empty', false
                  else
                    $t.val placeholder
                    $t.data 'empty', true
                    $t[0].type = "" if password
      
      # Multipurpose PopUp
      PopUp:
        
        # Fade duration default, feel free to change
        FADE_DURATION: 250
        
        # After the DOM is load
        load: ->
          unless $('#_pop-up').length
          
            # Shortcut
            o = _.PopUp;

            # Until 'display: box' becomes more widely available, we're stuck with tables for cross-browser centering
            $('body').append o.$table =
              $('<table><tbody><tr><td><div/></td></tr></tbody></table>')
                .attr(
                  id: '#_pop-up-table')
                .css
                  display: 'none'
                  position: 'fixed'
                  zIndex: 999999
                  left: 0
                  top: 0
                  borderCollapse: 'collapse'
                  opacity: 0
            o.hide()
            o.$td =
              o.$table.find('td')
                .css
                  textAlign: 'center'
                  verticalAlign: 'middle'
            o.$div =
              o.$td.find('div')
                .attr
                  id: '#_pop-up'
            $(window).on 'scroll resize orientationchange', o.correct
            o.$td.on 'click', -> o.$div.find('._pop-up-outside').click()
            o.$div
              .on('click', false)
              .on 'click', '._pop-up-hide', o.hide
            $(document).keydown (e) ->
              if o.$table.css('display') is 'block' and not $('body :focus').length
                switch e.keyCode
                  when 13 then o.$div.find('._pop-up-enter').click()
                  when 27 then o.$div.find('._pop-up-esc').click()
                  else return true
                false
            o.correct()
                    
        # Match the PopUp size to the window
        correct: ->
          _.PopUp.$td.width($(window).width()).height $(window).height()
          
        # Fade the PopUp out
        hide: (fadeDuration) ->
          o = _.PopUp
          o.$table
            .stop()
            .animate
              opacity: 0
            , fadeDuration ? o.$table.data('fadeDuration')
            , -> o.$table.css 'display', 'none'
          
        # Show the PopUp with the given `html`, optionally for a duration
        show: (html, opt) ->
          o = _.PopUp
          opt = _.extend
            duration: null
            callback: null
            fadeDuration: o.FADE_DURATION
          , opt
          $('body :focus').blur()
          o.$div.html html
          o.$table
            .data(
              fadeDuration: opt.fadeDuration)
            .stop()
            .css(
              display: 'block')
            .animate
              opacity: 1
            , opt.fadeDuration
          clearTimeout o.timer if o.timer?
          o.timer = setTimeout ->
            o.hide()
            opt.callback?()
          , opt.duration if opt.duration
      
      # Search (as you type)
      Search:
        
        # Check for Search objects to be initialized
        dom: ->
          $('*[data-search]').each ->
            $search = $ @
            if not $search.data('cache')?
              o = _.Search
              $search.data
                cache: []
                id: 0
                ajax: {}
                lastQ: null
                page: 0
                holdHover: false
                $q: $search.find('.q').attr(autocomplete: 'off')
                $results: $search.find '.results'
              $q = $search.data('$q')
              $results = $search.data '$results'
              o.query $search if $q.is ':focus'
              $search.hover(->
                $search.data hover: true
              , ->
                $search.data hover: false
                $results.css display: 'none' unless $q.is(':focus') or $search.data 'holdHover'
              ).mouseover ->
                $search.data holdHover: false
              $q.blur(->
                setTimeout ->
                  $results.css display: 'none' unless $search.data 'hover'
                , 0
              ).focus(->
                $search.data holdHover: false
              ).keydown((e) ->
                switch e.keyCode
                  when 13 then $search.find('.selected').click()
                  when 38 then o.select $search, 'prev'
                  when 40 then o.select $search, 'next'
                  when 27
                    setTimeout ->
                      $results.css display: 'none'
                    , 0
                    $q.blur()
                  else
                    setTimeout ->
                      o.query $search if $q.is ':focus'
                    , 0
                    return true
                false
              ).on 'focus keyup change', ->
                o.query $search
              $results.on('mouseenter', '.result', ->
                $results.find('.result.selected').removeClass 'selected'
                $(@).addClass 'selected'
              ).on 'click', '.result', ->
                $t = $ @
                $results.find('.result.selected').removeClass 'selected'
                $t.addClass 'selected'
                if $t.hasClass 'prev'
                  o.page $search, $search.data('page')-1, true
                  $search.data holdHover: true
                else if  $t.hasClass 'next'
                  o.page $search, $search.data('page')+1
                  $search.data holdHover: true
                else if $t.hasClass 'submit'
                  $t.parents('form').submit()
                if $t.hasClass 'hide-search'
                  $q.blur()
                  $results.css display: 'none'
        
        # Change the current search results page
        page: ($searches, n, prev) ->
          $searches.each ->
            $search = $ @
            $results = $search.data '$results'
            n = Math.min $results.find('.page').length-1, Math.max n, 0
            $results.find('.result.selected').removeClass 'selected'
            $results.find('.page').css('display', 'none').eq(n).removeAttr('style').find('.result:not(.prev):not(.next)')[if prev then 'last' else 'first']().addClass 'selected'
            $search.data 'page', n
        
        # Send the value of q to the correct search function and return the result to the correct callback
        query: ($searches, urlN = 1) ->
          $searches.each ->
            o = _.Search
            $search = $ @
            $results = $search.data '$results'
            $q = $search.data '$q'
            callback = eval $search.data('search')
            q = o.parseQuery $q.val()
            t = new Date().getTime()
            $results.css display: 'block'
            empty = 'empty' of $search.data
            unless q or empty
              $results.css(display: 'none').html ''
              $search.removeClass 'loading'
            else if q isnt $search.data('lastQ') or urlN > 1
              callback $search
              clearTimeout $search.data 'timeout'
              $search.data('ajax').abort?()
              if $search.data('cache')["#{urlN}_"+q]?
                callback $search, $search.data('cache')["#{urlN}_"+q], urlN
                $search.removeClass 'loading'
                o.query $search, urlN+1 if $search.data("url#{urlN+1}")?
              else
                $search.addClass('loading').data 'timeout',
                  setTimeout ->
                    handleData = (data) ->
                      $search.data('cache')["#{urlN}_"+q] = data
                      if check is $search.data('id') and o.parseQuery($q.val()) or empty
                        $search.removeClass 'loading'
                        callback $search, data, urlN
                      o.query $search, urlN+1 if $search.data 'url'+(urlN+1)
                    check = $search.data(id: $search.data('id')+1).data 'id'
                    if $search.data('js')?
                      handleData eval($search.data 'js')(q)
                    else if $search.data('url')?
                      $search.data ajax: $.getJSON($search.data("url#{if urlN is 1 then '' else urlN}"), q: q, handleData)
                  , $search.data('delay') ? 0
            $search.data 'lastQ', q
        
        # Select the next or previous in a list of results
        select: ($searches, dir) ->
          $searches.each ->
            o = _.Search
            $search = $ @
            $page = $search.find('.page').eq $search.data 'page'
            $page.find('.result')[if dir is 'prev' then 'first' else 'last']().addClass 'selected' unless $page.find('.result.selected').removeClass('selected')[dir]().addClass('selected').length
            if $page.find('.result.selected').hasClass 'prev'
              o.page $search, $search.data('page')-1, true
            else if $page.find('.result.selected').hasClass 'next'
              o.page $search, $search.data('page')+1
      
        # Break a query up into components if colons are used
        parseQuery: (str) ->
          str = _.clean str, downcase: true
          colon = _.compact str.split ':'
          if colon.length > 1
            colon = _.map colon, (str) -> _.strip(str).match /(?:^|^(.*) )(\w+)$/
            terms = {}
            _.each colon, (match, i) ->
              if i < colon.length-1
                terms[match[2]] = colon[i+1][1]
              else
                prev = colon[i-1][2]
                terms[prev] = (terms[prev] ? terms[prev]+' ' : '')+match[2]
            terms
          else
            str
           
      # Yay tooltips!
      Tooltip:
      
        # Store mouse coordinates
        mouse:
          x: 0
          y: 0
      
        # Set mousemove on document to track coordinates
        load: ->
          o = _.Tooltip
          $('body').mousemove (e) ->
            o.mouse =
              x: e.pageX
              y: e.pageY
            $('*[data-tooltip]').each ->
              $t = $ @
              $t.data('$div').css o.position($t).home if $t.data('$div')? and $t.data('mouse')?
                  
        dom: ->
          $('*[data-tooltip]').each ->
            o = _.Tooltip
            $t = $ @
            unless $t.data('$div')?
              $t.parent().css position: 'relative' if $t.parent().css position: 'static'
              $t.data hoverable: null if $t.data('mouse')?
              $t.data _.extend
                position: 'top',
                offset: 0,
                duration: 0,
                mouse: null,
                hoverable: null
              , $t.data()
              $div = $('<div><div/></div>')
                .addClass("_tooltip #{$t.data('position')}")
                .css
                  display: 'none'
                  position: 'absolute'
                  zIndex: 999999;
              $div
                .find('> div')
                .html($t.data('tooltip'))
                .css
                  position: 'relative'
              $t
                .data($div: $div)
                .parent()
                .append $div
              position = o.position($t)
              $div
                .css(position.home)
                .find('> div')
                .css _.extend {opacity: 0}, position.away
              $t
                .on('mouseenter focus', (e) ->
                  _.Tooltip.show $t
                  $t.data 'hover', true if e.type is 'mouseenter')
                .on 'mouseleave blur', (e) ->
                  $t.data 'hover', false if e.type is 'mouseleave'
                  _.Tooltip.hide $t
              
              # If the tooltip is 'hoverable' (aka it should stay while the mouse is over the tooltip itself)
              if $t.data('hoverable')? and not $t.data('mouse')?
                $div.hover ->
                  _.Tooltip.show $t
                  $(@).data hover: true
                , ->
                  $(@).data hover: false
                  _.Tooltip.hide $t
              else
              
                # Otherwise turn off interaction with the mouse
                $div.css
                  pointerEvents: 'none'
                  '-webkit-user-select': 'none'
                  '-moz-user-select': 'none'
                  userSelect: 'none'
                      
        # Show the tooltip if it's not already visible
        show: ($t) ->
          $div = $t.data '$div'
          unless $t.data('hover') or $t.is(':focus') or $div.data 'hover'
            position = _.Tooltip.position($t)
            $div
              .appendTo($t.parent())
              .css(_.extend {display: 'block'}, position.home)
              .find('> div')
              .stop()
              .animate
                opacity: 1
                top: 0
                left: 0
              , $t.data 'duration'
        
        # Hide the tooltip if it's not already hidden
        hide: ($t) ->
          $div = $t.data '$div'
          unless $t.data('hover') or $t.is ':focus' or $div.data 'hover'
            position = _.Tooltip.position($t)
            $div
              .css(position.home)
              .find('> div')
              .stop()
              .animate _.extend({opacity: 0}, position.away),
                duration: $t.data 'duration'
                complete: -> $(@).parent().css display: 'none'
        
        # Method for getting the correct CSS position data for a tooltip
        position: ($t) ->
          o = _.Tooltip
          $div = $t.data '$div'
          offset = $t.data 'offset'
          divWidth = $div.outerWidth()
          divHeight = $div.outerHeight()
          if $t.data('mouse')?
            tLeft = o.mouse.x-$t.parent().offset().left
            tTop = o.mouse.y-$t.parent().offset().top
            tWidth = tHeight = 0
          else
            tPosition = $t.position()
            tLeft = tPosition.left+parseInt $t.css 'marginLeft'
            tTop = tPosition.top+parseInt $t.css 'marginTop'
            tWidth = $t.outerWidth()
            tHeight = $t.outerHeight()
          home =
            left: tLeft
            top: tTop
          away = {}
          switch $t.data('position')
            when 'top'
              home.left += (tWidth-divWidth)/2
              home.top -= divHeight
              away.top = -offset
            when 'right'
              home.left += tWidth
              home.top += (tHeight-divHeight)/2
              away.left = offset
            when 'bottom'
              home.left += (tWidth-divWidth)/2
              home.top += tHeight
              away.top = offset
            when 'left'
              home.left -= divWidth
              home.top += (tHeight-divHeight)/2
              away.left = -offset
          {home: home, away: away}
      
      #
      # Looking into Backbone as a replacement for my lovely State class
      #
      State:
        xhr: {}
        cache: {}
        
        # The attributes below are optional and can be set at runtime as needed
        
        # When true, forces State to reload the page on the next request.
        # refresh: false
        
        # Specify a query parameter to send with the XHR request
        # query: 'pushState'
        
        load: ->
          o = _.State
          if history.state?
            history.replaceState true, null
          $(window).on 'popstate', (e) ->
            if e.originalEvent.state?
              o.push location.href
            else
              history.replaceState true, null
          $("body").on 'click', '.push-state', ->
            $t = $ @
            o.push if $t.data 'url' then $t.data 'url' else $t.attr 'href'
            false
        updateCache: (url, obj) ->
          o = _.State
          if o.cache[url]?
            _.extend o.cache[url], obj
          else
            o.cache[url] = obj
        push: (url) ->
          o = _.State
          url = _.url url
          if location.protocol is url.match(/^\w+:/)[0] and history.pushState? and not o.refresh
            o.xhr.abort?()
            o.clear o.cache[url], url
            if o.cache[url]? and o.cache[url].cache isnt false
              o.change url
            else
              o.before o.cache[url], url
              o.xhr = $.getJSON(url+(if o.query then (if '?' in url then '&' else '?')+o.query else ''), null, (data) ->
                o.updateCache url, data
                o.after o.cache[url], url
                o.change url
              ).error -> location.assign url
          else
            location.assign url
        change: (url) ->
          o = _.State
          history.pushState true, null, url if location.href isnt url
          o.parse o.cache[url], url
        clear: ->
        before: ->
        after: ->
        parse: ->
      
      # Load images only when they're on the page or about to be on it
      Lazy:
      
        # Default tolerance, can be overidden here or with data-tolerance='xxx'
        TOLERANCE: 100
        
        # After the DOM is ready
        load: ->
          o = _.Lazy
          $(window).on 'scroll resize', o.dom
                    
        # Check for new lazy images
        dom: ->
          $('img[data-lazy]').each ->
            visible = _.reduce $t.parents, (memo, parent) ->
              memo and $(parent).css('display') isnt 'none' and $(parent).css('visibility') isnt 'hidden'
            , true
            if visible && $(window).scrollTop()+$(window).outerHeight() >= $t.offset().top-($t.data('tolerance') ? _.Lazy.TOLERANCE)
              url = $t.data 'lazy'
              $t.removeAttr('data-lazy').attr 'src', url
      
      # Everyone's favorite cheat code        
      Konami: (callback, onlyOnce = false, code = '38,38,40,40,37,39,37,39,66,65,13', touchCode = 'up,up,down,down,left,right,left,right,tap,tap,tap') ->
        keysPressed = []
        touchEvents = []
        tap = false
        startX = startY = dX = dY = 0
        keyDownEvent = (e) ->
          keysPressed.push e.keyCode
          if _.endsWith keysPressed+'', code
            $(document).off 'keydown', keyDownEvent if onlyOnce
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
            rightLeft = if dX > 0 then 'right' else 'left'
            downUp = if dY > 0 then 'down' else 'up'
            val = if Math.abs(dX) > Math.abs dY then rightLeft else downUp
            touchEvents.push val
            tap = false
            checkEvents e
        touchEndEvent = (e) ->
          e = e.originalEvent
          if e.touches.length is 0 and tap
            touchEvents.push 'tap'
            checkEvents e
        checkEvents = (e) ->
          if _.endsWith touchEvents+'', touchCode
            if onlyOnce
              $(document).off 'touchmove', touchMoveEvent
              $(document).off 'touchend', touchEndEvent
            touchEvents = []
            e.preventDefault()
            callback()
        $(document).on 'keydown', keyDownEvent
        $(document).on 'touchstart', touchStartEvent
        $(document).on 'touchmove', touchMoveEvent
        $(document).on 'touchend', touchEndEvent
        
      # Making Cookie management easy on you
      Cookie: (name, val, opt = {}) ->
        if typeof name is 'object'
          _.Cookie n, v, val for n, v of name
        else if typeof name is 'string' and val isnt undefined
          opt.expires = -1 if val is null
          val ||= ''
          params = []
          params.push "; Expires=#{if opt.expires.toGMTString? then opt.expires.toGMTString() else new Date(new Date().getTime()+opt.expires*1000*60*60*24).toGMTString()}" if opt.expires
          params.push "; Path=#{opt.path}" if opt.path
          params.push "; Domain=#{opt.domain}" if opt.domain
          params.push '; HttpOnly' if opt.httpOnly
          params.push '; Secure' if opt.secure
          document.cookie = "#{encodeURIComponent name}=#{encodeURIComponent val}#{params.join ''}"
        else
          cookies = {}
          if document.cookie
            _.each decodeURIComponent(document.cookie).split(/\s*;\s*/), (cookie) ->
              {1: n, 2: v} = /^([^=]*)\s*=\s*(.*)$/.exec cookie
              if typeof name is 'string' and name is n
                return v
              else if not name?
                cookies[n] = v
          if not name then cookies else null
  
  # Mixin the Extrascore Mixins
  _.mixin Extrascore.Mixins
  
  # Extend the Extrascore Extensions
  _.extend _, Extrascore.Extensions
  
  # Initialize the Extrascore Extensions
  _.init Extrascore.Extensions
