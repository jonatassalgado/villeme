class ItemsController < ApplicationController
  require_relative '../../app/services/account/is_account_complete'

  before_action :set_item, only: [:show, :edit, :update, :destroy, :schedule]

  # access for only logged users
  before_action :is_logged, only: [:new, :edit, :create, :update]

  # access only for admin users
  before_action :is_admin, only: [:index, :aprove, :destroy]

  layout 'fullwidth_layout'


  include Gmaps


  def index
    @items = get_item_class.all
    render template: "#{get_item_route}/index"
  end


  def show
    require_relative '../../app/domain/dependecies/javascript_dependencies'

    if user_signed_in?
      @distance = current_user.distance_until(@item, :minutes)
    end

    @tip = Tip.new

    # geolocalization of event
    gon.latitude = @item.relative_latitude
    gon.longitude = @item.relative_longitude

    # array with places for map
    gon.events_local_formatted = format_for_map_this(Item.all)

    render template: 'items/show'
  end



  def new

    unless AccountService.is_account_complete?(current_user)
      redirect_to root_path, alert: 'Você precisa estar com o perfil completo para criar um evento!'
    end

    @item = current_user.items.build(type: params[:type])
    @place = @item.build_place

    set_current_user_lat_long_in_gon
    set_array_of_places_in_gon

    if get_item_route == 'items'
      render template: "#{get_item_route}/new", layout: 'centralize-lg' and return
    end

    render template: "#{get_item_route}/new"
  end



  def edit

    if @item.user_id == current_user.id or current_user.admin?
      @item.build_place if @item.place.nil?

      set_array_of_places_in_gon

      gon.latitude = @item.relative_latitude
      gon.longitude = @item.relative_longitude

      render template: 'items/edit'
    else
      redirect_to root_path, notice: 'Ops! Você so pode editar os eventos que criou.'
    end
  end



  def create
    @item = current_user.items.create(item_params)
    set_type_for_item
    auto_moderate_if_admin
    set_place_for_item

    if @item.save
      redirect_item_according_type
    else
      render action: 'new', alert: 'O evento não pode ser criado, arrume as informações abaixo.'
    end
  end




  def update
    @item.update_attributes(item_params)
    auto_moderate_if_admin
    set_place_for_item

    if @item.save
      redirect_item_according_type
    else
      render action: 'new', alert: 'O evento não pode ser atualizado, arrume as informações abaixo.'
    end
  end




  def destroy
    @item.destroy
    redirect_to events_url
  end



  def aprove
    @item = Item.find params[:id]
    @item.moderate = 1
    @item.save!
    render js: "alert('Evento aprovado!');"
  end


  def schedule
    if current_or_guest_user.guest?
      render js: 'Villeme.Ux.loginModal("Você precisa estar logado para agendar eventos!")'
    elsif agended(@item)
      current_user.unschedule(@item)
      agended_by_count = @item.agended_by_count
      render json: {agended: false, event: "event-#{@item.id}", count: current_user.items_agenda.upcoming.count, agended_by_count: agended_by_count[:count], new_title: agended_by_count[:text]}
    else
      current_user.schedule(@item)
      agended_by_count = @item.agended_by_count
      render json: {agended: true, event: "event-#{@item.id}", count: current_user.items_agenda.upcoming.count, agended_by_count: agended_by_count[:count], new_title: agended_by_count[:text]}
    end
  end



  def full_description
    @item = Item.friendly.find(params[get_item_id])
    render json:{full_description: @item.description}
  end


  private

  def set_item
    # @item = Event.find(params[:id])
    @item = Item.friendly.find(params[:id])
  end


  def set_city
    if @item.place.neighborhood.city.nil?
      @city = current_user.city
    else
      @city = @item.place.neighborhood.city
    end
  end


  def item_params
    params.require(get_item_class(text: true).downcase).permit(
        :name,
        :description,
        :address,
        :number,
        :date_start,
        :date_finish,
        :cost,
        :cost_details,
        :hour_start_first,
        :hour_start_second,
        :hour_start_third,
        :hour_start_fourth,
        :hour_start_fifth,
        :hour_start_sixth,
        :hour_finish_first,
        :hour_finish_second,
        :hour_finish_third,
        :hour_finish_fourth,
        :hour_finish_fifth,
        :hour_finish_sixth,
        :latitude,
        :longitude,
        :place_id,
        :price_id,
        :image,
        :link,
        :email,
        :phone,
        :allday,
        :all_year,
        :type,
        :subcategory_ids => [],
        :category_ids => [],
        :persona_ids => [],
        :week_ids => [],
        :place_attributes => []
    )
  end

  def set_type_for_item
    @item.type = get_item_class(text: true)
  end

  def auto_moderate_if_admin
    @item.moderate = 1 if current_or_guest_user.admin?
  end

  def set_place_for_item
    object_place_name = params[get_item_class(text: true).downcase][:place_attributes][:name]
    if object_place_name
      place = Place.find_by name: object_place_name
      if place.nil?
        place = current_user.places.new(name: object_place_name)
        @item.copy_attributes_to place
        @item.place = place
      else
        place.copy_attributes_to @item
        @item.place = place
      end
    end
  end



  def set_current_user_lat_long_in_gon
    if user_signed_in?
      gon.current_user_latitude = current_user.latitude
      gon.current_user_longitude = current_user.longitude
    end

    set_array_of_places_in_gon
  end

  def set_array_of_places_in_gon
    places_array = Array.new
    Place.all.each do |place|
      places_array << {label: place.name, value: place.id}
    end

    gon.places_array = places_array
  end

  def get_item_route
    if params[:type] != nil
      "#{params[:type].downcase.pluralize}"
    elsif @item and @item.type != nil
      @item.type.downcase.pluralize
    else
      'items'
    end
  end

  def get_item_id
    if params[:type] == 'Event'
      "#{params[:type].downcase}_id"
    elsif params[:type] == 'Activity'
      "#{params[:type].downcase}_id"
    else
      'id'
    end
  end

  def get_item_class(options = {text: false})
    if params[:type] != nil
      options[:text] ? params[:type] : params[:type].constantize
    elsif @item and @item.type != nil
      options[:text] ? @item.type : @item.type.constantize
    else
      options[:text] ? 'Item' : 'Item'.constantize
    end
  end

  def redirect_item_according_type
    if @item.type == 'Event'
      redirect_to event_path @item, notice: 'O evento foi  criado com sucesso!'
    elsif @item.type == 'Activity'
      redirect_to activity_path @item, notice: 'A atividade foi  criado com sucesso!' and return
    else
      redirect_to @item, notice: 'O item foi  criado com sucesso!'
    end
  end



end
