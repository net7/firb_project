# a foo model used to display all the elements in a book (TaliaCore::Collection)
# as a list of FiParadeCartCard and FiCharacterCard 
class FiCarte


  def self.menu_items_for(collection)
    anastaticas = Anastatica::menu_items_for(collection)
    result = []
    anastaticas.each do |a|
      tmp = FiParadeCartCard.find(:first, :find_through => [N::DCT.isPartOf, a])
      tmp = FiCharacterCard.find(:first, :find_through => [N::DCT.isPartOf, a]) if tmp.nil?
      result << tmp unless tmp.nil?
    end
    result
  end

end
