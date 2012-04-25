if not Blackmailr? and Extrascore?
  $ = jQuery
  window.Blackmailr =
    Ui:
      load: ->
        # Set the countdown timer to update '.countdown' classes every second
        Blackmailr.Ui.countdown()
        setInterval Blackmailr.Ui.countdown, 1000
      
      countdown: ->
        now = new Date()
        $('.countdown').each ->
          $t = $ @
          s = -Math.floor (now - new Date $t.data('countdownSeconds')*1000)/1000
          if $t.is 'img'
            w = $t.width()
            h = $t.height()
            l = $t.position().left
            t = $t.position().top
            if w and h
              unless $t.data 'mask'
                $t.data mask: $('<div>')
                                .css(
                                  background: '#000',
                                  position: 'absolute',
                                  width: w,
                                  height: h,
                                  left: l,
                                  top: t
                                ).appendTo $t.parent()
              $mask = $t.data 'mask'
              if s <= 0
                $mask.remove()
              else
                scalar = .5 + (s / (10 * 60)) * .5
                $mask.css
                  width: scalar*w
                  height: scalar*h
                  left: l+(w-scalar*w)/2
                  top: t+(h-scalar*h)/2
              $t.css visibility: 'visible'
          else
            if s <= 0
              html = 'EXPIRED'
            else
              html = []
              s -= (d = Math.floor s/(60*60*24))*(60*60*24)
              html.push "#{d}d" if d or html.length
              s -= (h = Math.floor s/(60*60))*(60*60)
              html.push "#{d}h" if h or html.length
              s -= (m = Math.floor s/60)*60
              html.push "#{m}m" if m or html.length
              html.push "#{s}s"
              html = html.join ' '
            $t.html html
        
  _.init Blackmailr
