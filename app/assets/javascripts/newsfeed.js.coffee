
#= require riot/riot.min
#= require components/items-section.js
#= require components/item.js
#= require components/sidebar-left.js
#= require gmap3
#= require gmaps-builder-user
#= require bLazy/blazy

@Villeme = @Villeme or {}

Villeme.Newsfeed = ( ->

  initialize = ->
    $(document).on 'ready page:done', ->
      fixingMapOnScroll()
      initGoogleMaps()
      return

    saveScrollToReturnAfterAjax()
    return


  initGoogleMaps = ->
    if $('#main').is(':visible')
      setTimeout(->
        new Gmaps(gon.latitude, gon.longitude)

        map = $('#map').gmap3("get")
        google.maps.event.trigger(map, "resize");
        Gmaps.centerTo(gon.latitude, gon.longitude)
      , 350)
    else
      $(document).on 'page:done', ->
        setTimeout(->
          Gmaps.clearMarker()
          new Gmaps(gon.latitude, gon.longitude)

          map = $('#map').gmap3("get")
          google.maps.event.trigger(map, "resize")
          Gmaps.centerTo(gon.latitude, gon.longitude)
        , 350)
        return
    return

  userEvent = ->
    # map mouseenter
    $("#map").mouseenter ->
      # limpa o timeout
      i = 0
      while i < timeouts.length
        clearTimeout timeouts[i]
        i++

      timeouts = []
      # ---
      return

    return

  saveScrollToReturnAfterAjax = ->
    @Villeme.tempNewsfeedPage = window.location.href;
    @Villeme.tempScroll = @Villeme.tempScroll or 0

    $(document).on 'page:done', ->
      setTimeout( ->
        if window.location.href == Villeme.tempNewsfeedPage
          $(window).scrollTop(Villeme.tempScroll)
        else
          $(window).scrollTop(0)
      , 75)
      return
    return


  fixingMapOnScroll = ->
    position = 0

    $(window).scroll ->
      scroll = $(window).scrollTop()
      if scroll > position
        $('.js-FixingMapOnScroll').css({top: scroll})
      else
        $('.js-FixingMapOnScroll').css({top: scroll})

      position = scroll
      return

    return


  bLazy = ->
    bLazy = new Blazy(
      success: (ele) ->

        return
      error: (ele, msg) ->
        if msg == 'blazy missing'
          console.log msg
        else if msg == 'blazy invalid'
          console.log msg
        else
        return
    )

    $(document).on 'page:done', ->
      bLazy.revalidate()
      return

    return


  initialize()

  return {
    createMap: ->
      if $('#main').is(':visible')
        setTimeout(->
          new Gmaps(gon.latitude, gon.longitude)

          map = $('#map').gmap3("get")
          google.maps.event.trigger(map, "resize");
          Gmaps.centerTo(gon.latitude, gon.longitude)
        , 350)
      else
        $(document).on 'page:done', ->
          setTimeout(->
            Gmaps.clearMarker()
            new Gmaps(gon.latitude, gon.longitude)

            map = $('#map').gmap3("get")
            google.maps.event.trigger(map, "resize")
            Gmaps.centerTo(gon.latitude, gon.longitude)
          , 350)
          return
      return
  }

)()











