# A procession is a group of at most one cart and any number of characters in
# a parade of the FIRB FI data model
class ParadeProcession < TaliaCore::SourceTypes::DcResource
  
  singular_property :first_member, N::TALIA.first, :force_relation => true
  singular_property :last_member, N::TALIA.last, :force_relation => true
  
end