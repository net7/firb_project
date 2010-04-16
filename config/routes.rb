ActionController::Routing::Routes.draw do |map|
  map.resources :oai

  map.site_search  'search', :controller => 'admin/front', :action => 'search'

  Hobo.add_routes(map)
  map.admin '/admin', :controller => 'admin/front', :action => 'index'
  map.connect '/admin/import/:action', :controller => 'admin/import'
  map.connect '/admin/talia_sources/:action/:id', :controller => 'admin/talia_sources'
  map.connect '/admin/talia_collections/:action/:id', :controller => 'admin/talia_collections'
  

  map.connect '/test/:action/:id', :controller => 'test'
  map.connect '/admin/firb_images/:action/:id', :controller => 'admin/firb_images'
  map.connect '/admin/firb_image_zones/:action/:id', :controller => 'admin/firb_image_zones'
  map.connect '/admin/firb_text_pages/:action/:id', :controller => 'admin/firb_text_pages'
  map.connect '/admin/firb_illustrated_memory_depiction_pages/:action/:id', :controller => 'admin/firb_text_pages'
  map.connect '/admin/iconclass_terms/:action/:id', :controller => 'admin/iconclass_terms'
  
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

  # Default semantic dispatch
  map.connect ':dispatch_uri.:format', :controller => 'sources', :action => 'dispatch',
    :requirements => { :dispatch_uri => /[^\.]+/ }

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

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  # # map.connect ':controller/:action/:id.:format'
end
