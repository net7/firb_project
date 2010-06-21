module FiCards
  
  def test_create_cart_with_procession
    setup_procession
    login_for(:admin)
    assert_difference('FiParadeCartCard.count', 1) do
      assert_difference('@procession.size', 1) do
        post :create, :fi_parade_cart_card => { :name => "Foobar", :procession => @procession.uri.to_s }, :type => 'fi_parade_cart_card'
        assert_redirected_to :controller => :base_cards, :action => :index
        @procession.reload
      end
    end
    new_card = FiParadeCartCard.last
    assert_not_nil(new_card.procession)
    assert_equal('Foobar', new_card.name)
    assert_equal(new_card.procession.uri, @procession.uri)
  end
  
  def test_create_with_existing_cart
    setup_procession
    login_for(:admin)
    cart_two = FiParadeCartCard.new(:name => "CiaoCiao", :procession => @procession)
    cart_two.save!
    assert_difference('FiParadeCartCard.count', 0) do
        post :create, :fi_parade_cart_card => { :name => "Foobar", :procession => @procession.uri.to_s }, :type => 'fi_parade_cart_card'
        assert_response :success
        assert_select "div.error-messages" 
    end
  end
  
  def setup_procession
    @procession = FiProcession.new(:title => "Corteo")
    @procession.save!
  end

end