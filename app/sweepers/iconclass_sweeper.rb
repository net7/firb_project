class IconclassSweeper < ActionController::Caching::Sweeper
  observe IllustrationCard

  def after_save(illustrationCard)
    expire_cache_for(illustrationCard)
  end

  def after_destroy(illustrationCard)
    expire_cache_for(illustrationCard)
  end

  private
  
  def expire_cache_for(illustrationCard)
    params = []

    expire_page(url_for(:only_path => true, :type => false, :controller => '/boxview/indici', :action => 'show_grouped_iconclass'))

  end

end

