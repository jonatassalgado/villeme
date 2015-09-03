#=require events/input

(($) ->

  EventForm =

    init: ->
      # EventForm.inputTransitions()
      EventForm.opacityOnInputsNotRequireds()
      EventForm.removeImageFromUpload()
      EventForm.activeHelper()
      EventForm.applyPluginFileStyle()
      EventForm.addMoreHours()
      EventForm.moneyMask()
      EventForm.moreDetails()
      EventForm.descriptionTextTools()
      EventForm.datePickerTime()
      EventForm.dateTimeSectionHideShow()
      return


    inputTransitions: ->
      $("#event-form .has-focus-transition").each ->
        @input_assync = $(this)
        @input = new Input($(this))

        @input_assync.keyup ->
          console.log "Keyuped"
          @input.validSize()
          return

        return

      return


    opacityOnInputsNotRequireds: ->
      $(".not-required").mouseenter ->
        $(this).removeClass("not-required")
        return

      return


    removeImageFromUpload: ->
      $(".remove-img").click ->
        $(".event-img").css("background-image":"none")
        $(":file").filestyle('clear')
        $(".event-text").text("Enviar imagem")
        $(".event-img").removeClass("green-font green-border")
        return

      return

    applyPluginFileStyle: ->
      $(":file").filestyle
        buttonText: "Enviar imagem..."
        classButton: "btn btn-default"
        input: false

      $(".event-img").parents(".form-group").mouseover ->
        fileName = $("#event_image").val()

        if fileName
          $(".event-text").text("Imagem enviada!")
          $(".event-img").addClass("green-font green-border")
        else
          $(".event-text").text("Sem imagem")
          $(".event-img").removeClass("green-font green-border")

        return

      $(".image-upload").click ->
        $("#event_image").click()
        return

      return

    activeHelper: ->
      $(".has-helper").mouseenter ->
        helper = $(this).attr("helper")
        $(".helper-text").html("")
        $("#helper").fadeIn()
        $(".helper-text").html(helper)
        return

        $(".panel").mouseleave ->
          $("#helper").fadeOut()
          return

      return

    addMoreHours: ->
      $(".AddHour").click ->
        $(this).parents(".hour-block").next(".hour-block").fadeIn()
        return

      return


    moneyMask: ->
      $('#event_cost_fake, #event_cost').maskMoney
        prefix: "R$ "
        allowNegative: false
        thousands: "."
        decimal: ","
        affixesStay: false


      $("#event_cost_fake").focusout ->
        dinheiro = $("#event_cost_fake").val()
        dinheiroConvertido = dinheiro.replace(",", ".").replace("R$","")
        $("#event_cost").val(dinheiroConvertido)
        return

      return



    moreDetails: ->
      $(".not-required-show").click ->
        $(this).hide()
        $(".not-required-block").show()
        return

      return


    dateTimeSectionHideShow: ->
      $('.js-date-timepicker').focus ->
        $('.js-datetime-section-hide-show').removeClass('is-Hidden').addClass('is-Visible')
        return
      return

    descriptionTextTools: ->
      $("#js-item-description").jqte
        center: false
        color: false
        fsize: false
        funit: false
        format: false
        indent: false
        left: false
        right: false
        outdent: false
        rule: false
        source: false
        sub: false
        sup: false
        focus: ->
          $(".jqte_editor").animate
            'height': 360
          return
        blur: ->
          $(".jqte_editor").animate
            'height': 100
          return
      return

    datePickerTime: ->
      jQuery('#date_timepicker_start').datetimepicker
        lang: 'pt-BR'
        format: 'd/m/Y'
        onShow: (ct) ->
          @setOptions
            maxDate: if jQuery('#date_timepicker_end').val() then jQuery('#date_timepicker_end').val() else false
            formatDate:'d/m/Y'
          return
        timepicker: false
      jQuery('#date_timepicker_end').datetimepicker
        lang: 'pt-BR'
        format: 'd/m/Y'
        onShow: (ct) ->
          @setOptions
            minDate: if jQuery('#date_timepicker_start').val() then jQuery('#date_timepicker_start').val() else false
            formatDate:'d/m/Y'
          return
        timepicker: false

      return



  $ ->
    EventForm.init()
    return


  return

) jQuery




$(document).on 'ready page:done', ->

  # SHOW -------------------------------------------

  url = $(location).attr('href')

  # Descrição completa
  $(".read-more, .snippet").click ->
    $.ajax(
      url:  url + "/fulldescription"
    ).done (data) ->

      $(".read-more").hide()

      description = data.full_description
      $(".EventSingle-description").removeClass("snippet").html(description)
      return
    return


  # Nova dica
  $("#new-tip").on 'ajax:success', (event, data, status, xhr) ->
    if data.valid
      $(".tips").prepend("<li class='list-group-item'><b>" + data.user + "</b> - " + data.description + " — <span class='grey-font-50'>Há " + data.created_at + "</span></li>")
    else
      $(".tips").prepend("<li class='list-group-item'><b>Você so pode enviar 2 dicas por evento.</b></li>")

    return

  $("#tip_description").keyup ->
    max = 140
    len = $(this).val().length
    if len >= max
      $(".tip-counter b").text "Sua dica precisa ter menos de 140 caracteres."
    else
      char = max - len
      $(".tip-counter b").text char + " caracteres."
    return

  return