###! Extrascore (requires jQuery and Underscore) by Casey Foster (caseywebdev.com) ###

# Check dependencies
if not Extrascore? and jQuery? and _?
  
  # Use the jQuery shortcut
  $ = jQuery
  
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
        $.trim(str.replace /\s+/g, ' ').replace /\ /g, opt.delimiter
      
      # This sucker comes in handy
      startsWith: (str, start) ->
        str = str+''
        start = start+''
        return start.length <= str.length and str.substr(0, start.length) is start
      
      # This guys too
      endsWith: (str, end) ->
        str = str+''
        end = end+''
        return end.length <= str.length and str.substr(-end.length) is end      
      
      # Sort an object by key for iteration
      sortByKey: (obj) ->
        newObj = {}
        _.chain(obj)
          .map((val, key) -> [key, val])
          .sortBy((val) -> val[0])
          .each (val) -> newObj[val[0]] = val[1]
        newObj
      
      # A quick zip to the top of the page, or optionally to an integer or jQuery object specified by `val`
      scrollTo: (val = 0, duration, callback) ->
        if val instanceof $
          val = val.offset().top
        $(if $.browser.webkit then document.body else document.documentElement).animate scrollTop: val, duration, callback
      
      # Get a full URL from a relative url
      url: (path = '', protocol = location.protocol) ->
        
        # Append a colon to the protocol if necessary
        protocol += ':' unless _.endsWith protocol, ':'
        
        # See if it's already a URL
        unless path.match /^\w+:/
        
          # See if it's a URL looking for a protocol
          if _.startsWith path, '//'
            path = location.protocol+path
          
          # See if it's relative to the domain root
          else if _.startsWith path, '/'
            path = location.protocol+'//'+location.host+path
            
          # Otherwise it must be relative to the current location
          else
            path = location.href+path
        
        # Swap the protocols if necessary
        path.replace location.protocol, protocol
    
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
              if $(@).data 'placeholderEmpty' then '' else $(@)._val()
                  
        # Check for new inputs or textareas than need to be initialized with Placeholder
        dom: ->
          $('input[data-placeholder], textarea[data-placeholder]').each ->
            $t = $ @
            # Strings to CONSTANTS for minification
            PLACEHOLDER = 'placeholder'
            PASSWORD = 'password'
            PLACEHOLDER_EMPTY = 'placeholderEmpty'
            if $t.data(PLACEHOLDER)? and not $t.data(PLACEHOLDER_EMPTY)?
              password = $t.data('placeholderPassword')?
              placeholder = $t.data PLACEHOLDER
              $t[0].type = PASSWORD if password
              unless password and $.browser.msie and $.browser.version.split('.') < 9
                if not $t.val() or $t.val() is placeholder
                  $t.data PLACEHOLDER_EMPTY, true
                  $t.val placeholder
                  $t[0].type = '' if password
                else
                  $t.data PLACEHOLDER_EMPTY, false
                $t.attr
                  placeholder: placeholder
                  title: placeholder
                $t.focus(->
                  $t.val '' if $t.data PLACEHOLDER_EMPTY
                  if password
                    $t[0].type = PASSWORD
                    $t.attr PLACEHOLDER, placeholder
                  $t.data PLACEHOLDER_EMPTY, false
                ).blur ->
                  if $t.val()
                    $t.data PLACEHOLDER_EMPTY, false
                  else
                    $t.val placeholder
                    $t.data PLACEHOLDER_EMPTY, true
                    $t[0].type = '' if password
      
      # Multipurpose PopUp
      PopUp:
        
        # Duration and Fade duration default, feel free to change
        DURATION: 0
        FADE_DURATION: 250
        
        # Build the PopUp element
        build: ->
          # Shortcut
          o = _.PopUp;
          unless $('#pop-up-container').length
            
            # Until 'display: box' becomes more widely available, we're stuck with line-height and vertical-align
            $('body').append o.$container =
              $('<div><div><div/></div></div>')
                .attr(
                  id: 'pop-up-container'
                ).css
                  display: 'none'
                  position: 'fixed'
                  zIndex: 999999
                  left: 0
                  top: 0
                  opacity: 0
                  textAlign: 'center'
            o.hide()
            o.$div =
              o.$container.find('> div')
                .attr(
                  id: 'pop-up'
                ).css
                  display: 'inline-block'
                  lineHeight: 'normal'
                  verticalAlign: 'middle'
            #o.$div.attr
                  # IE inline-block hack...
                  #style: o.$div.attr('style')+' *zoom: 1; *display: inline'
            $(window).on 'scroll resize orientationchange', o.correct
            o.$container.on 'click', -> o.$div.find('*[data-pop-up-outside]').click()
            o.$div
              .on('click', false)
              .on 'click', '*[data-pop-up-hide]', o.hide
            $(document).keydown (e) ->
              if o.$container.css('display') is 'block' and not $('body :focus').length
                switch e.keyCode
                  when 13 then o.$div.find('*[data-pop-up-enter]').click()
                  when 27 then o.$div.find('*[data-pop-up-esc]').click()
                  else return true
                false
            o.correct()
                    
        # Match the PopUp size to the window
        correct: ->
          o = _.PopUp
          if o.$container?
            o.$container
              .css
                width: $(window).width()
                lineHeight: "#{$(window).height()}px"
          
        # Fade the PopUp out
        hide: (fadeDuration) ->
          o = _.PopUp
          if o.$container?
            o.$container
              .stop()
              .animate
                opacity: 0
              , (if isNaN(fadeDuration) then o.fadeDuration else fadeDuration)
              , -> o.$container.css display: 'none'
          
        # Show the PopUp with the given `html`, optionally for a duration
        show: (html, opt = {}) ->
          o = _.PopUp
          
          # Build the PopUp element
          o.build()
          
          opt = _.extend
            duration: o.DURATION
            callback: null
            fadeDuration: o.FADE_DURATION
          , opt
          $('body :focus').blur()
          o.fadeDuration = opt.fadeDuration
          o.$div.html html
          o.$container
            .stop()
            .css(
              display: 'block')
            .animate
              opacity: 1
            , opt.fadeDuration
          clearTimeout o.timeout if o.timeout?
          o.timeout = setTimeout ->
            o.hide()
            opt.callback?()
          , opt.duration if opt.duration
      
      # Search (as you type)
      Search:
        
        # Check for Search objects to be initialized
        dom: ->
          $('*[data-search]').each ->
            $search = $ @
            if not $search.data('searchCache')?
              o = _.Search
              $search.data
                searchCache: []
                searchId: 0
                searchAjax: {}
                searchLastQ: null
                searchPage: 0
                searchHoldHover: false
                search$Q: $search.find('.q').attr(autocomplete: 'off')
                search$Results: $search.find '.results'
              $q = $search.data('search$Q')
              $results = $search.data 'search$Results'
              o.query $search if $q.is ':focus'
              $search.hover(->
                $search.data searchHover: true
              , ->
                $search.data searchHover: false
                $results.css display: 'none' unless $q.is(':focus') or $search.data 'searchHoldHover'
              ).mouseover ->
                $search.data searchHoldHover: false
              $q.blur(->
                setTimeout ->
                  $results.css display: 'none' unless $search.data 'searchHover'
                , 0
              ).focus(->
                $search.data searchHoldHover: false
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
              $results.on 'mouseenter click', '.result', (e) ->
                $t = $ @
                $results.find('.result.selected').removeClass 'selected'
                $t.addClass 'selected'
                if e.type is 'click'
                  if $t.is('.prev')
                    o.page $search, $search.data('searchPage')-1, true
                    $search.data searchHoldHover: true
                  else if $t.is('.next')
                    o.page $search, $search.data('searchPage')+1
                    $search.data searchHoldHover: true
                  else if $t.is('.submit')
                    $t.parents('form').submit()
                  if $t.data('searchHide')?
                    $q.blur()
                    $results.css display: 'none'
        
        # Change the current search results page
        page: ($searches, n, prev) ->
          $searches.each ->
            $search = $ @
            $results = $search.data 'search$Results'
            n = Math.min $results.find('.page').length-1, Math.max n, 0
            $results.find('.result.selected').removeClass 'selected'
            $results.find('.page').css(display: 'none').eq(n).removeAttr('style').find('.result:not(.prev):not(.next)')[if prev then 'last' else 'first']().addClass 'selected'
            $search.data 'searchPage', n
        
        # Send the value of q to the correct search function and return the result to the correct callback
        query: ($searches, urlN = 1) ->
          $searches.each ->
            o = _.Search
            $search = $ @
            $results = $search.data 'search$Results'
            $q = $search.data 'search$Q'
            callback = eval $search.data('search')
            q = o.parseQuery $q.val(), $search.data('searchColonSplitQuery')?
            t = new Date().getTime()
            $results.css display: 'block'
            unless q or $search.data('searchEmpty')?
              $results.css(display: 'none').html ''
              $search.removeClass 'loading'
            else if q isnt $search.data('searchLastQ') or urlN > 1
              callback $search
              clearTimeout $search.data 'searchTimeout'
              $search.data('searchAjax').abort?()
              if $search.data('searchCache')["#{urlN}_"+q]?
                callback $search, $search.data('searchCache')["#{urlN}_"+q], urlN
                $search.removeClass 'loading'
                o.query $search, urlN+1 if $search.data("searchUrl#{urlN+1}")?
              else
                $search.addClass('loading').data 'searchTimeout',
                  setTimeout ->
                    handleData = (data) ->
                      $search.data('searchCache')["#{urlN}_"+q] = data
                      if check is $search.data('searchId') and o.parseQuery($q.val()) or $search.data('searchEmpty')?
                        $search.removeClass 'loading'
                        callback $search, data, urlN
                      o.query $search, urlN+1 if $search.data 'searchUrl'+(urlN+1)
                    check = $search.data(searchId: $search.data('searchId')+1).data 'searchId'
                    if $search.data('searchJs')?
                      handleData eval($search.data 'searchJs')(q)
                    else if $search.data('searchUrl')?
                      $search.data searchAjax: $.getJSON($search.data("searchUrl#{if urlN is 1 then '' else urlN}"), q: q, handleData)
                  , $search.data('searchDelay') ? 0
            $search.data 'searchLastQ', q
        
        # Select the next or previous in a list of results
        select: ($searches, dir) ->
          $searches.each ->
            o = _.Search
            $search = $ @
            $page = $search.find('.page').eq $search.data 'searchPage'
            $page.find('.result')[if dir is 'prev' then 'first' else 'last']().addClass 'selected' unless $page.find('.result.selected').removeClass('selected')[dir]().addClass('selected').length
            if $page.find('.result.selected.prev').length
              o.page $search, $search.data('searchPage')-1, true
            else if $page.find('.result.selected.next').length
              o.page $search, $search.data('searchPage')+1
      
        # Break a query up into components if colons are used
        parseQuery: (str, colonSplit = false) ->
          str = _.clean str, downcase: true
          colon = _.compact str.split ':'
          if colonSplit and colon.length > 1
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
          $('body').mousemove((e) ->
            o.mouse =
              x: e.pageX
              y: e.pageY
            $('*[data-tooltip]').each ->
              $t = $ @
              $t.data('tooltip$Div').css o.position($t).home if $t.data('tooltip$Div')? and $t.data('tooltipMouse')?
          ).on('mouseenter', '*[data-tooltip]:not([data-tooltip-no-hover])', ->
            $t = $ @
            o.show $t
            $t.data tooltipHover: true
          ).on('mouseleave', '*[data-tooltip]:not([data-tooltip-no-hover])', ->
            $t = $ @
            $t.data tooltipHover: false
            o.hide $t
          ).on('focus', '*[data-tooltip]:not([data-tooltip-no-focus])', ->
            o.show $ @
          ).on('blur', '*[data-tooltip]:not([data-tooltip-no-focus])', ->
            o.hide $ @
          )
        
        # Get the current tooltip$Div for an item or create a new one and return that
        divFor: ($t) ->
          o = _.Tooltip
          unless $t.data 'tooltip$Div'
            $t.parent().css position: 'relative' if $t.parent().css position: 'static'
            $t.data tooltipHoverable: null if $t.data('tooltipMouse')?
            $t.data _.extend
              tooltipPosition: 'top'
              tooltipOffset: 0
              tooltipDuration: 0
              tooltipNoHover: null
              tooltipNoFocus: null
              tooltipMouse: null
              tooltipHoverable: null
              tooltipHoverableHover: null
            , $t.data()
            $div = $('<div><div/></div>')
              .addClass("tooltip #{$t.data('tooltipPosition')}")
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
              .data(tooltip$Div: $div)
              .parent()
              .append $div
            position = o.position($t)
            $div
              .css(position.home)
              .find('> div')
              .css _.extend {opacity: 0}, position.away
            
            # If the tooltip is 'hoverable' (aka it should stay while the mouse is over the tooltip itself)
            if $t.data('tooltipHoverable')?
              $div.hover ->
                _.Tooltip.show $t
                $t.data tooltipHoverableHover: true
              , ->
                $t.data tooltipHoverableHover: false
                _.Tooltip.hide $t
            else
            
              # Otherwise turn off interaction with the mouse
              $div.css
                pointerEvents: 'none'
                '-webkit-user-select': 'none'
                '-moz-user-select': 'none'
                userSelect: 'none'
          $t.data 'tooltip$Div'
                             
        # Show the tooltip if it's not already visible
        show: ($t) ->
          o = _.Tooltip
          $div = o.divFor $t
          unless  (not $t.data('tooltipNoHover')? and $t.data 'tooltipHover') or
                  (not $t.data('tooltipNoFocus')? and $t.is ':focus') or
                  $t.data 'tooltipHoverableHover'
            position = o.position($t)
            $div
              .appendTo($t.parent())
              .css(_.extend {display: 'block'}, position.home)
              .find('> div')
              .stop()
              .animate
                opacity: 1
                top: 0
                left: 0
              , $t.data 'tooltipDuration'
        
        # Hide the tooltip if it's not already hidden
        hide: ($t) ->
          o = _.Tooltip
          if $div = $t.data 'tooltip$Div'
            unless  (not $t.data('tooltipNoHover')? and $t.data 'tooltipHover') or
                    (not $t.data('tooltipNoFocus')? and $t.is ':focus') or
                    $t.data 'tooltipHoverableHover'
              position = o.position($t)
              $div
                .css(position.home)
                .find('> div')
                .stop()
                .animate _.extend({opacity: 0}, position.away),
                  duration: $t.data 'tooltipDuration'
                  complete: ->
                    $t.data tooltip$Div: null
                    $(@).parent().remove()
        
        # Method for getting the correct CSS position data for a tooltip
        position: ($t) ->
          o = _.Tooltip
          $div = $t.data 'tooltip$Div'
          offset = $t.data 'tooltipOffset'
          divWidth = $div.outerWidth()
          divHeight = $div.outerHeight()
          if $t.data('tooltipMouse')?
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
          switch $t.data('tooltipPosition')
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
        
        # Use this to correct the placeholder content and positioning between events if necessary
        correct: ($t) ->
          o = _.Tooltip
          $div = $t.data 'tooltip$Div'
          if $div
            if $t.css('display') is 'none'
              console.log 'yip'
              $t.mouseleave().blur()
            else
              $div.find('> div').html($t.data('tooltip'))
              $div.css _.Tooltip.position($t).home
      
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
          $("body").on 'click', '*[data-state]', ->
            $t = $ @
            o.push (if $t.data 'stateUrl' then $t.data 'stateUrl' else $t.attr 'href'), $t.data 'stateProtocol'
            false
        updateCache: (url, obj) ->
          o = _.State
          if o.cache[url]?
            _.extend o.cache[url], obj
          else
            o.cache[url] = obj
        push: (url, protocol = location.protocol) ->
          o = _.State
          url = _.url url, protocol
          if history.pushState? and not o.refresh and _.startsWith url, location.protocol
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
        
          # Wait for the browser to position the element on the page before checking its coordinates via setTimeout fn, 0
          setTimeout ->
            $('img[data-lazy]').each ->
              $t = $ @
              visible = _.reduce $t.parents(), (memo, parent) ->
                memo and $(parent).css('display') isnt 'none' and $(parent).css('visibility') isnt 'hidden'
              , true
              if visible && $(window).scrollTop()+$(window).outerHeight() >= $t.offset().top-($t.data('lazyTolerance') ? _.Lazy.TOLERANCE)
                url = $t.data 'lazy'
                $t.removeAttr('data-lazy').attr 'src', url
          , 0
      
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
