ActionController::Routing::Routes.draw do |map|
  map.resources :oai

  map.site_search  'search', :controller => 'admin/front', :action => 'search'

  Hobo.add_routes(map)
  
  map.admin '/admin', :controller => 'admin/front', :action => 'index'
  map.connect '/admin/import/:action', :controller => 'admin/import'
  map.connect '/admin/talia_sources/:action/:id', :controller => 'admin/talia_sources'
  map.connect '/admin/talia_collections/:action/:id', :controller => 'admin/talia_collections'
  
  map.connect '/test/:action/:id', :controller => 'test', :id => nil
  map.connect '/admin/images/:action/:id', :controller => 'admin/images', :id => nil
  map.connect '/admin/image_zones/:action/:id', :controller => 'admin/image_zones', :id => nil
  map.connect '/admin/pi_text_cards/:action/:id', :controller => 'admin/pi_text_cards', :id => nil
  map.connect '/admin/fi_text_cards/:action/:id', :controller => 'admin/fi_text_cards', :id => nil
  map.connect '/admin/vt_handwritten_text_cards/:action/:id', :controller => 'admin/vt_handwritten_text_cards', :id => nil
  map.connect '/admin/vt_printed_text_cards/:action/:id', :controller => 'admin/vt_printed_text_cards', :id => nil
  map.connect '/admin/bg_text_cards/:action/:id', :controller => 'admin/bg_text_cards', :id => nil
  map.connect '/admin/pi_illustrated_md_cards/:action/:id', :controller => 'admin/pi_illustrated_md_cards', :id => nil
  map.connect '/admin/iconclass_terms/:action/:id', :controller => 'admin/iconclass_terms', :id => nil
  map.connect '/admin/base_cards/:action/:id', :controller => 'admin/base_cards', :action => 'index', :id => nil

  map.connect '/admin/base_cards/show_annotable/:id', :controller => 'admin/text_cards', :action => 'show_annotable'
  map.connect '/admin/text_cards/show_preview/:id', :controller => 'admin/text_cards', :action => 'show_preview'

  map.connect '/admin/publish/toggle/:id', :controller => 'admin/publish', :action => "toggle"
  map.connect '/admin/publish/post_annotated', :controller => 'admin/publish', :action => "post_annotated"
 
  map.connect 'swicky_notebooks/context/:action', :controller => 'swicky_notebooks'
  map.resources :swicky_notebooks, :path_prefix => 'users/:user_name'

  # Ontologies
  map.resources :ontologies

  # Routes for the source data
  map.connect 'source_data/:id', :controller => 'source_data',
    :action => 'show'

  map.connect 'source_data/:type/:location', :controller => 'source_data',
    :action => 'show_tloc',
    :requirements => { :location => /[^\/]+/ } # Force the location to match also filenames with points etc.

  map.resources :data_records, :controller => 'source_data'

  # Routes for types
  map.resources :types

  # Routes for the sources
  map.connect 'sources/:action/:id', :controller => 'sources'
  map.resources :sources, :requirements => { :id => /.+/  }


  # Old box view (Deprecated, soon to be removed)
  map.connect '/boxView', :controller => 'boxView', :action => 'index'
  map.connect '/boxView/dispatch', :controller => 'boxView', :action => 'dispatch'
  map.connect '/boxView/graph_xml/:id', :controller => 'boxView', :action => 'graph_xml'

  # New boxview
  # map.connect '/boxview', :controller => 'boxview', :action => 'index'
  map.boxview '/boxview', :controller => 'boxview/base', :action => 'index'
  map.boxview_anastatica '/boxview/anastatiche/:id', :controller => 'boxview/anastatiche', :action => 'show'
  map.boxview_illustrazione_madre '/boxview/illustrazioni_madri/:id', :controller => 'boxview/illustrazioni_madri', :action => 'show'
  map.boxview_illustrazione_figlia '/boxview/illustrazioni_figlie/:id', :controller => 'boxview/illustrazioni_figlie', :action => 'show'
  map.boxview_capolettera '/boxview/capolettera/:id', :controller => 'boxview/capolettera', :action => 'show'
  map.boxview_pi_scheda_testo '/boxview/pi_scheda_testo/:id', :controller => 'boxview/pi_scheda_testo', :action => 'show'
  map.connect '/boxview/indici', :controller => 'boxview/indici', :action => "index" 
  map.connect '/boxview/indici/pi', :controller => 'boxview/indici', :action => "pi" 
  map.connect '/boxview/indici/fi', :controller => 'boxview/indici', :action => "fi" 
  map.connect '/boxview/indici/:collection/:type', :controller => 'boxview/indici', :action => "show"
  map.connect '/boxview/indici/:collection/:type/:subtype', :controller => 'boxview/indici', :action => "show_filtered"
  map.connect '/boxview/pagine_statiche/:action', :controller => 'boxview/pagine_statiche'

  map.with_options(:namespace => "boxview/", :path_prefix => 'boxview', :only => :show) do |boxview|
    boxview.resources :fi_parade_cart_cards
  end

  # Default semantic dispatch
  map.connect ':dispatch_uri.:format', :controller => 'sources', :action => 'dispatch',
    :requirements => { :dispatch_uri => /[^\.]+/ }

  #  map.connect ':dispatch_uri.:format', :controller => 'boxView', :action => 'dispatch',
  #    :requirements => { :dispatch_uri => /[^\.]+/ }
 

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  #  map.root :controller => "boxView", :action => 'index'
  map.root :controller => "sources", :action => 'index'
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  # # map.connect ':controller/:action/:id.:format'
end
