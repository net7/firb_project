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
    { :controller => 'boxview/illustrazioni_lettera', 
      :title => "Capolettera #{desc}", 
      :description => desc,
      :res_id => "pi_letter_illustration_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

end
