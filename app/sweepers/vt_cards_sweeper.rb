class VtCardsSweeper < ActionController::Caching::Sweeper
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


    expire_page(url_for(:only_path => true, :type => false, :controller => '/boxview/vt_handwritten_text_cards', :action => 'show', :id => illustrationCard.id))

  end

end

