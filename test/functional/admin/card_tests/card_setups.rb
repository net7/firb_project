module CardSetups
  
  def setup_iconclass
    @iconclasses = []
    @iconclass_arr = []
    @iconclass_term_arr = []
    (0..1).each do |idx|
      iconclass = IconclassTerm.create_term(:term => "61 E (+#{idx})", 
        :pref_label => 'foo', 
        :alt_label => 'bar',
        :soundex => 'meep',
        :note => 'Cool' )
      iconclass.save!
      @iconclasses << iconclass
      @iconclass_arr << iconclass.uri.to_s
      @iconclass_term_arr << iconclass.term
    end
  end
  
  def setup_image_zone
    @image_zone = FirbImageZone.create_with_name('hello')
    @image_zone.save!
  end

  def setup_bibliographies
    @bibliographies = []
    (0..2).each do |idx|
      bibliography = BibliographyItem.new(:title => "bib_#{idx}")
      bibliography.save!
      @bibliographies << bibliography
    end
    @bibliography_arr = @bibliographies.collect { |bib| bib.uri.to_s }
  end

  def setup_page
    @page = FirbAnastaticaPage.new(:title => "meep", :page_positon => "1", :name => "first page")
    @page.save!
    @page
  end
  
end