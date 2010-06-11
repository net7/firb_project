module FiCards
  
  def test_create_cart_with_procession
    setup_procession
    login_for(:admin)
    assert_difference('FirbParadeCartCard.count', 1) do
      assert_difference('@procession.size', 1) do
        post :create, :firb_parade_cart_card => { :name => "Foobar", :procession => @procession.uri.to_s }, :type => 'parade_cart'
        assert_redirected_to :controller => :firb_cards, :action => :index
        @procession.reload
      end
    end
    new_card = FirbParadeCartCard.last
    assert_not_nil(new_card.procession)
    assert_equal('Foobar', new_card.name)
    assert_equal(new_card.procession.uri, @procession.uri)
  end
  
  def test_create_with_existing_cart
    setup_procession
    login_for(:admin)
    cart_two = FirbParadeCartCard.new(:name => "CiaoCiao", :procession => @procession)
    cart_two.save!
    assert_difference('FirbParadeCartCard.count', 0) do
        post :create, :firb_parade_cart_card => { :name => "Foobar", :procession => @procession.uri.to_s }, :type => 'parade_cart'
        assert_template :new
    end
  end
  
  # 
  # def test_create_cart_with_parade
  #   setup_image_zone
  #   setup_parade
  #   login_for(:admin)
  #   assert_difference('@parade.size', 1) do
  #     post :create, :firb_parade_cart_card => { :name => "Foobar", :parade => @parade.uri.to_s }, :type => 'parade_cart'
  #     assert_redirected_to :controller => :firb_cards, :action => :index
  #     @parade.reload
  #   end
  #   new_card = FirbParadeCartCard.last
  #   assert_not_nil(new_card.parade)
  #   assert_equal(new_card.parade.uri, @parade.uri)
  # end
  # 
  # def test_create_character_with_collection
  #   setup_image_zone
  #   setup_collection
  #   login_for(:admin)
  #   assert_difference('FirbParadeCharacterCard.count', 1) do
  #     assert_difference('@collection.size', 1) do
  #       post :create, :firb_parade_character_card => { :name => "Foobar", :collection => @collection.uri.to_s }, :type => 'parade_character'
  #       assert_redirected_to :controller => :firb_cards, :action => :index
  #       @collection.reload
  #     end
  #   end
  #   new_card = FirbParadeCharacterCard.last
  #   assert_equal('Foobar', new_card.name)
  # end
  # 
  # def test_create_character_with_parade
  #   setup_image_zone
  #   setup_parade
  #   login_for(:admin)
  #   assert_difference('@parade.size', 1) do
  #     post :create, :firb_parade_character_card => { :name => "Foobar", :parade => @parade.uri.to_s }, :type => 'parade_character'
  #     assert_redirected_to :controller => :firb_cards, :action => :index
  #     @parade.reload
  #   end
  # end
  #
  
  def setup_procession
    @procession = Procession.new(:title => "Corteo")
    @procession.save!
  end

end