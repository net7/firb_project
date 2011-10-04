class PiCardsSweeper < ActionController::Caching::Sweeper
  observe PiTextCard

  def after_save(piTextCard)
    expire_cache_for(piTextCard)
  end

  def after_destroy(piTextCard)
    expire_cache_for(piTextCard)
  end

  private
  
  def expire_cache_for(piTextCard)
    params = []
    coll = TaliaCore::Collection.first.id
    expire_page(url_for(:only_path => true, :type => false, :controller => "/boxview/indici/#{coll}/anastaticas"))
    expire_page(url_for(:only_path => true, :type => false, :controller => "/boxview/indici/#{coll}/pi_illustration_cards"))

  end
end

