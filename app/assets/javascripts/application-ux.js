this.Villeme = this.Villeme || {};

Villeme.Ux = (function() {
  var ajaxTransition, alerts, categoriesAnimateOnSidebar, destroyAnimation, hoverActions, initialize, modalFeedback, sidebarLeft;

  initialize = (function() {
    $(document).ready(function() {
      destroyAnimation();
      alerts();
      sidebarLeft();
      categoriesAnimateOnSidebar();
    });
  })();

  ajaxTransition = (function() {
    $(document).ready(function() {
      window.wiselinks = new Wiselinks($('#main'), {
        html4: false
      });
    });
    $(document).on('page:loading', function() {
      NProgress.start();
    });
    return $(document).on('ready page:done', function() {
      NProgress.done();
    });
  })();

  destroyAnimation = function() {
    $(".excluir").click(function() {
      var anchor;
      anchor = $(this).attr("data-anchor");
      $(this).parents(anchor).fadeOut("slow");
    });
  };

  alerts = function() {
    $(".alert").animate({
      "top": 0
    }, 900);
    if ($(".alert")) {
      setTimeout(function() {
        $(".alert").animate({
          "top": "-100px"
        }, 900);
      }, 12000);
    }
    $(".alert .close").click(function() {
      $(".alert").animate({
        "top": "-100px"
      }, 900);
    });
  };

  sidebarLeft = function() {
    $(".sub-nav-anchor").click(function() {
      $(this).next(".sub-nav").toggleClass("hide");
    });
  };

  modalFeedback = (function() {
    return $('#modal-feedback').on('ajax:success', function(event, data, status, xhr) {
      $(this).modal("hide");
      $("body").prepend('<div class="alert fade in alert-success alert-dismissable" style="top: 0;"> <button class="close" type="button" data-dismiss="alert" aria-hidden="true">×</button> Enviado com sucesso. Obrigado! </div>');
      setTimeout(function() {
        $(".alert").animate({
          "top": "-100px"
        }, 500);
      }, 6000);
    });
  })();

  hoverActions = (function() {
    $(document).on('mouseenter', '.has-hover-action', function() {
      var class_toggle, data_hover;
      data_hover = $(this).attr("data-text-hover");
      class_toggle = $(this).attr("data-class-hover");
      $(this).text(data_hover);
      $(this).toggleClass(class_toggle);
    });
    return $(document).on('mouseleave', '.has-hover-action', function() {
      var class_toggle, data_default;
      data_default = $(this).attr("data-text-default");
      class_toggle = $(this).attr("data-class-hover");
      $(this).text(data_default);
      $(this).toggleClass(class_toggle);
    });
  })();

  categoriesAnimateOnSidebar = function() {
    if ((matchMedia('only screen and (min-width : 992px)').matches)) {
      $("#sidebar-left-md").mouseover(function() {
        $(".content").addClass("active");
      });
      $("#sidebar-left-md").mouseleave(function() {
        $(".content").removeClass("active");
      });
    }
  };

  return {
    loginModal: function(text, callback) {
      var $loginModal = $(".js-ModalLogin");

      $loginModal.modal("toggle");
      if (text !== void 0) {
        $(".js-ModalLogin-alert").html(text);
      } else {
        $(".js-Modal-alert").html("");
      }

      setTimeout(function(){
        if(callback != null){
          callback()
        }
      }, 1000)

    },

    openRequestInviteModal: function(){
      $(".js-ModalRequestInvite").modal("toggle");
    }
  };

})();
