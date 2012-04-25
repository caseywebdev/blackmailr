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
          text = Blackmailr.Ui.secondsToText s
          if $t.is 'img'
            w = $t.width()
            h = $t.height()
            l = $t.position().left
            t = $t.position().top
            if w and h
              unless $t.data 'mask'
                $t.data mask: $('<div>')
                                .css(
                                  background: '#000'
                                  position: 'absolute'
                                  width: w
                                  lineHeight: h + 'px'
                                  left: l
                                  top: t
                                  color: '#fff'
                                  textAlign: 'center'
                                  fontSize: 50
                                ).appendTo $t.parent()
              $mask = $t.data 'mask'
              if s <= 0
                $mask.remove()
              else
                scalar = .75 + (s / (10 * 60)) * .25
                $mask
                  .text(text)
                  .css
                    width: scalar * w
                    lineHeight: scalar * h + 'px'
                    left: l + (w - scalar * w) / 2
                    top: t + (h - scalar * h) / 2
              $t.css visibility: 'visible'
          else
            $t.text text
            
      secondsToText: (s) ->
        if s <= 0
          'EXPIRED'
        else
          text = []
          s -= (d = Math.floor s/(60*60*24))*(60*60*24)
          text.push "#{d}d" if d or text.length
          s -= (h = Math.floor s/(60*60))*(60*60)
          text.push "#{d}h" if h or text.length
          s -= (m = Math.floor s/60)*60
          text.push "#{m}m" if m or text.length
          text.push "#{s}s"
          text.join ' '
          
  _.init Blackmailr
