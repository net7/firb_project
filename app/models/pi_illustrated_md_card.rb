class PiIllustratedMdCard < IllustrationCard

  include StandardPermissions
  extend Mixin::Showable
  showable_in PiIllustrationCard

  include Mixin::Searchable

  autofill_uri :force => true

  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
  singular_property :transcription_text, N::TALIA.transcription
  declare_attr_type :transcription_text, :text
  singular_property :parent_card, N::TALIA.parent_card, :type => TaliaCore::ActiveSource
  singular_property :content_type, N::DCT.type

  def iconclasses(sort=true)
    super(sort, false)
  end

  def boxview_data
    desc = self.short_description.nil? ? "" : self.short_description
    { :controller => 'boxview/illustrazioni_figlie', 
      :title => "Scheda immagine di memoria: #{desc}", 
      :description => desc,
      :res_id => "pi_illustration_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def is_public?
    true
  end

  def parts_query
    ActiveRDF::Query.new(TaliaCore::ActiveSource).select(:part).where(self, N::TALIA.image_component,:part)
  end

  # not really needed, TBH
  def self.menu_items_for(collection)
    result = []
    cards = self.find(:all)
    cards.each do |c|
      result << c unless c.nil?
    end
    result.compact
  end
end
