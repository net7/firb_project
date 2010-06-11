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
        assert_response :success
        assert_select "div.error-messages" 
    end
  end
  
  def setup_procession
    @procession = Procession.new(:title => "Corteo")
    @procession.save!
  end

end