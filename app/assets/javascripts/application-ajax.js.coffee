(($) ->
  App =

    ###*
    Inicia as funções
    ###
    init: ->
      App.BellNotification()
      App.AgendaButton()
      App.FriendActions()
      App.NewsfeedNotification()
      return




    ###*
    Notificações de amizade
    ###
    BellNotification: ->
      $(document).on 'click', '.Button--navbar', ->
        $.ajax(
          url: "/notify/bell"
        ).done (data) ->
          if data.success
            $(this).removeClass("is-active")
            $("#bell").removeClass("is-ring")
          return
        return

      return



    ###*
    Notificações do newsfeed
    ###
    NewsfeedNotification: ->
      $(document).on 'click', '#newsfeed-link', ->
        $.ajax(
          url: "/notify/newsfeed"
        ).done (data) ->
          if data.success
            $("#newsfeed-link").find(".badge").html("")

          return
        return

      return




    ###*
    Ativa o botão para agendar eventos
    ###
    AgendaButton: ->
      $(document).on 'click', '.js-EventAgendaButton', ->
        $(this).find(".js-EventButtonText").text("Agendando...")

        $.ajax(
          url: $(this).attr("data-schedule-url")
        ).done (data) ->

          event = $("."+data.event)
          agended = data.agended
          agenda_new_count = data.count
          agended_by_new_count = data.agended_by_count
          new_title = data.new_title

          if agended
            event.find(".js-EventAgendaButton").addClass("is-schedule")
            event.find(".js-EventButtonText").text("Agendado")
            event.find(".js-EventDayButton").addClass("is-schedule")
          else
            event.find(".js-EventAgendaButton").removeClass("is-schedule")
            event.find(".js-EventButtonText").text("Agendar")
            event.find(".js-EventDayButton").removeClass("is-schedule")

          _agendaCounterRefresh(agenda_new_count)
          event.find(".js-agendedByCount").text("").text(agended_by_new_count)
          event.find(".js-agendedByCount").attr("title", new_title)

          return
        return

      _agendaCounterRefresh = (new_value) ->
        $(".js-agendaCounter").text("").text(new_value)
        return

      return





    ###
    Controla a requisição, aceitação e destruição de amizades
    ###
    FriendActions: ->
      # Requisição de amizade
      $(document).on 'click', '.friend-request', ->
        $.ajax(
          url: "/friendships/request"
          data:
            friend: $(this).attr("data-friend-object")
        ).done (data) ->
          if data.success
            friend = $("#friend-"+data.friend_id)
            btn = $("#friend-btn-"+data.friend_id)
            friend.attr "data-content", "<button class='btn btn-success'>Amizade solicitada</button>"
            btn.text("Amizade solicitada").toggleClass("btn-default btn-success")

          return
        return

      # Aceitar amizade
      $(document).on 'click', '.friend-accept .btn', ->
        $.ajax(
          url: "/friendships/accept"
          data:
            friend: $(this).attr("data-friend-object")
        ).done (data) ->
          if data.success
            $friend = $("#friend-"+data.friend_id)
            $friend.fadeOut('fast').remove()
            $(".Button--navbar").attr("data-content", $(".popover-content").html())


          return
        return

      # Desfazer amizade
      $(document).on 'click', '.friend-destroy', ->
        $.ajax(
          url: "/friendships/destroy"
          data:
            friend: $(this).attr("data-friend-object")
        ).done (data) ->
          if data.success
            friend = $("#friend-"+data.friend_id)
            friend.attr "data-content", "<button class='btn btn-success'>Amizade desfeita</button>"

          return
        return

      return



  $ ->
    App.init()
    return



  return
) jQuery