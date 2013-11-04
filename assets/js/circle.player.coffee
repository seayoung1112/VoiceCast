#=require jquery.transform
#=require jquery.grab
#=require mod.csstransforms.min
#=require jplayer

CirclePlayer = (jPlayerSelector, media, options) ->
  self = this
  defaults =
    
    # solution: "flash, html", // For testing Flash with CSS3
    supplied: "m4a, oga"
    
    # Android 2.3 corrupts media element if preload:"none" is used.
    # preload: "none", // No point preloading metadata since no times are displayed. It helps keep the buffer state correct too.
    cssSelectorAncestor: "#cp_container_1"
    cssSelector:
      play: ".cp-play"
      pause: ".cp-pause"

  cssSelector =
    bufferHolder: ".cp-buffer-holder"
    buffer1: ".cp-buffer-1"
    buffer2: ".cp-buffer-2"
    progressHolder: ".cp-progress-holder"
    progress1: ".cp-progress-1"
    progress2: ".cp-progress-2"
    circleControl: ".cp-circle-control"

  @cssClass =
    gt50: "cp-gt50"
    fallback: "cp-fallback"

  @spritePitch = 104
  @spriteRatio = 0.24 # Number of steps / 100
  @player = $(jPlayerSelector)
  @media = $.extend({}, media)
  @options = $.extend(true, {}, defaults, options) # Deep copy
  @cssTransforms = Modernizr.csstransforms
  @audio = {}
  @dragging = false # Indicates if the progressbar is being 'dragged'.
  @eventNamespace = ".CirclePlayer" # So the events can easily be removed in destroy.
  @jq = {}
  $.each cssSelector, (entity, cssSel) ->
    self.jq[entity] = $(self.options.cssSelectorAncestor + " " + cssSel)

  @_initSolution()
  @_initPlayer()

CirclePlayer:: =
  _createHtml: ->

  _initPlayer: ->
    self = this
    @player.jPlayer @options
    @player.bind $.jPlayer.event.ready + @eventNamespace, (event) ->
      self.audio = $(this).data("jPlayer").htmlElement.audio  if event.jPlayer.html.used and event.jPlayer.html.audio.available
      $(this).jPlayer "setMedia", self.media
      self._initCircleControl()

    @player.bind $.jPlayer.event.play + @eventNamespace, (event) ->
      $(this).jPlayer "pauseOthers"

    
    # This event fired as play time increments
    @player.bind $.jPlayer.event.timeupdate + @eventNamespace, (event) ->
      self._timeupdate event.jPlayer.status.currentPercentAbsolute  unless self.dragging

    
    # This event fired as buffered time increments
    @player.bind $.jPlayer.event.progress + @eventNamespace, (event) ->
      percent = 0
      if (typeof self.audio.buffered is "object") and (self.audio.buffered.length > 0)
        if self.audio.duration > 0
          bufferTime = 0
          i = 0

          while i < self.audio.buffered.length
            bufferTime += self.audio.buffered.end(i) - self.audio.buffered.start(i)
            i++
          
          # console.log(i + " | start = " + self.audio.buffered.start(i) + " | end = " + self.audio.buffered.end(i) + " | bufferTime = " + bufferTime + " | duration = " + self.audio.duration);
          percent = 100 * bufferTime / self.audio.duration
      # else the Metadata has not been read yet.
      # console.log("percent = " + percent);
      else # Fallback if buffered not supported
        # percent = event.jPlayer.status.seekPercent;
        percent = 0 # Cleans up the inital conditions on all browsers, since seekPercent defaults to 100 when object is undefined.
      self._progress percent # Problem here at initial condition. Due to the Opera clause above of buffered.length > 0 above... Removing it means Opera's white buffer ring never shows like with polyfill.

    # Firefox 4 does not always give the final progress event when buffered = 100%
    @player.bind $.jPlayer.event.ended + @eventNamespace, (event) ->
      self._resetSolution()


  _initSolution: ->
    if @cssTransforms
      @jq.progressHolder.show()
      @jq.bufferHolder.show()
    else
      @jq.progressHolder.addClass(@cssClass.gt50).show()
      @jq.progress1.addClass @cssClass.fallback
      @jq.progress2.hide()
      @jq.bufferHolder.hide()
    @_resetSolution()

  _resetSolution: ->
    if @cssTransforms
      @jq.progressHolder.removeClass @cssClass.gt50
      @jq.progress1.css transform: "rotate(0deg)"
      @jq.progress2.css(transform: "rotate(0deg)").hide()
    else
      @jq.progress1.css "background-position", "0 " + @spritePitch + "px"

  _initCircleControl: ->
    self = this
    @jq.circleControl.grab
      onstart: ->
        self.dragging = true

      onmove: (event) ->
        pc = self._getArcPercent(event.position.x, event.position.y)
        self.player.jPlayer("playHead", pc).jPlayer "play"
        self._timeupdate pc

      onfinish: (event) ->
        self.dragging = false
        pc = self._getArcPercent(event.position.x, event.position.y)
        self.player.jPlayer("playHead", pc).jPlayer "play"


  _timeupdate: (percent) ->
    degs = percent * 3.6 + "deg"
    spriteOffset = (Math.floor((Math.round(percent)) * @spriteRatio) - 1) * -@spritePitch
    if percent <= 50
      if @cssTransforms
        @jq.progressHolder.removeClass @cssClass.gt50
        @jq.progress1.css transform: "rotate(" + degs + ")"
        @jq.progress2.hide()
      else # fall back
        @jq.progress1.css "background-position", "0 " + spriteOffset + "px"
    else if percent <= 100
      if @cssTransforms
        @jq.progressHolder.addClass @cssClass.gt50
        @jq.progress1.css transform: "rotate(180deg)"
        @jq.progress2.css transform: "rotate(" + degs + ")"
        @jq.progress2.show()
      else # fall back
        @jq.progress1.css "background-position", "0 " + spriteOffset + "px"

  _progress: (percent) ->
    degs = percent * 3.6 + "deg"
    if @cssTransforms
      if percent <= 50
        @jq.bufferHolder.removeClass @cssClass.gt50
        @jq.buffer1.css transform: "rotate(" + degs + ")"
        @jq.buffer2.hide()
      else if percent <= 100
        @jq.bufferHolder.addClass @cssClass.gt50
        @jq.buffer1.css transform: "rotate(180deg)"
        @jq.buffer2.show()
        @jq.buffer2.css transform: "rotate(" + degs + ")"

  _getArcPercent: (pageX, pageY) ->
    offset = @jq.circleControl.offset()
    x = pageX - offset.left - @jq.circleControl.width() / 2
    y = pageY - offset.top - @jq.circleControl.height() / 2
    theta = Math.atan2(y, x)
    theta = 2 * Math.PI + theta  if theta > -1 * Math.PI and theta < -0.5 * Math.PI
    
    # theta is now value between -0.5PI and 1.5PI
    # ready to be normalized and applied
    (theta + Math.PI / 2) / 2 * Math.PI * 10

  setMedia: (media) ->
    @media = $.extend({}, media)
    @player.jPlayer "setMedia", @media

  play: (time) ->
    @player.jPlayer "play", time

  pause: (time) ->
    @player.jPlayer "pause", time

  destroy: ->
    @player.unbind @eventNamespace
    @player.jPlayer "destroy"
