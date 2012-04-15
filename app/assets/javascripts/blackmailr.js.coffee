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
          s -= (d = Math.floor s/(60*60*24))*(60*60*24)
          s -= (h = Math.floor s/(60*60))*(60*60)
          s -= (m = Math.floor s/60)*60
          $t.html "#{d}d#{h}h#{m}m#{s}s"
        
  _.init Blackmailr
