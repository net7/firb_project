class FiCardsSweeper < ActionController::Caching::Sweeper
  observe IllustrationCard

  def after_save(illustrationCard)
    expire_cache_for(illustrationCard)
  end

  def after_destroy(illustrationCard)
    expire_cache_for(illustrationCard)
  end

  private
  
  def expire_cache_for(illustrationCard)
    expire_page(:controller => 'boxview/fi_vehicle_cards_controller', :action => 'show')
    expire_page(:controller => 'boxview/fi_animal_cards_controller', :action => 'show')
    expire_page(:controller => 'boxview/fi_character_cards_controller', :action => 'show')
    expire_page(:controller => 'boxview/fi_deity_cards_controller', :action => 'show')
    expire_page(:controller => 'boxview/fi_episode_cards_controller', :action => 'show')
    expire_page(:controller => 'boxview/fi_parade_cart_cards_controller', :action => 'show')
    expire_page(:controller => 'boxview/fi_throne_cards_controller', :action => 'show')
  end

end

