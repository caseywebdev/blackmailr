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
