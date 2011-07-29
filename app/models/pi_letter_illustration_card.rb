# Letter Illustration Card (Firb Pi): scheda capolettera
class PiLetterIllustrationCard < IllustrationCard

  include StandardPermissions
  extend Mixin::Showable
  showable_in Anastatica
  
  autofill_uri :force => true

  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components

  def boxview_data
    desc = self.description.nil? ? "" : "#{self.description.slice(0, 80)}.."
    { :controller => 'boxview/capolettera',
      :title => "Capolettera: #{self.anastatica.page_position}", 
      :description => desc,
      :res_id => "pi_letter_illustration_#{self.id}", 
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
      result << c  unless c.nil?
    end
    result
  end


end
