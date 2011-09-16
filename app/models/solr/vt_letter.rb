module SOLR
  class VtLetter < Base
    ::Sunspot.setup self do
      string :name
      string :title
      text   :introduction
      string :letter_number

      # rdf_property :letter_number, N::TALIA.letter_number, :type => :string
      # rdf_property :date, N::DCNS.date
      # rdf_property :date_string, N::TALIA.date_string, :type => :string
      # rdf_property :printed_collocation, N::TALIA.printed_collocation, :type => :string
      # rdf_property :handwritten_collocation, N::TALIA.handwritten_collocation, :type => :string
    end
  end
end


