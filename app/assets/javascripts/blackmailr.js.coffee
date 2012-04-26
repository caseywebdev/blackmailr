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
                    position: 'absolute'
                    width: 600
                    top: t
                  ).appendTo $t.parent()
                $('<div>')
                  .css(
                    background: '#000'
                    width: w
                    lineHeight: h + 'px'
                    margin: '0 auto'
                    color: '#fff'
                    textAlign: 'center'
                    fontSize: 50
                    whiteSpace: 'nowrap'
                  ).appendTo $t.data 'mask'
              $mask = $t.data 'mask'
              if s <= 0
                $mask.remove()
              else
                scalar = .75 + (s / (10 * 60)) * .25
                $mask
                  .css(top: t + (h - scalar * h) / 2)
                  .find('> div')
                  .text(text)
                  .css
                    width: scalar * w
                    lineHeight: scalar * h + 'px'
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
